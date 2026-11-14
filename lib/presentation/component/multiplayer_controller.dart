import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/domain/netcode/remote_dash_interpolator.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash/dash.dart';
import 'package:flappy_dash/presentation/component/flappy_dash_root_component.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'dash/dash_spawn_effect.dart';
import 'dash/dash_spawn_portal.dart';

class MultiplayerController extends Component
    with ParentIsA<FlappyDashRootComponent>, HasGameReference<FlappyDashGame> {
  MultiplayerController({super.priority});

  late StreamSubscription<MultiplayerState> _stateStreamSubscription;
  late StreamSubscription<MatchEvent> _eventStreamSubscription;

  final Map<String, _OtherDashBundle> _otherDashes = {};

  MultiplayerState? _previousState;
  late MultiplayerCubit _cubit;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _cubit = game.multiplayerCubit;
    _stateStreamSubscription = _cubit.stream.listen(_onNewState);
    _eventStreamSubscription = _cubit.matchEvents.listen(_onNewEvent);
  }

  void _onNewState(MultiplayerState state) {
    // Only the set of players matters here (adding and removing dashes);
    // positions and scores change on almost every state and are handled by
    // the events. Comparing the keys is also much cheaper than comparing
    // every player.
    final previous = _previousState;
    final players = state.matchState?.players;
    if (previous == null ||
        !_haveSamePlayers(previous.matchState?.players, players)) {
      _onPlayersUpdated(players);
    }

    _previousState = state;
  }

  static bool _haveSamePlayers(
    Map<String, PlayerState>? a,
    Map<String, PlayerState>? b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null || a.length != b.length) {
      return false;
    }
    for (final id in b.keys) {
      if (!a.containsKey(id)) {
        return false;
      }
    }
    return true;
  }

  void _onPlayersUpdated(Map<String, PlayerState>? players) {
    if (players == null) {
      _otherDashes.forEach(
        (_, dashBundle) => dashBundle.dash.removeFromParent(),
      );
      _otherDashes.clear();
      return;
    }

    // Remove players that are no longer in the game
    for (final entry in _otherDashes.entries.toList()) {
      if (!players.containsKey(entry.key)) {
        entry.value.dash.removeFromParent();
        _otherDashes.remove(entry.key);
      }
    }

    // Add new players that don't have a dash yet
    final myId = _cubit.state.currentAccount!.user.id;
    final otherPlayers = players.entries.where((entry) => entry.key != myId);
    for (final otherPlayer in otherPlayers) {
      if (!_otherDashes.containsKey(otherPlayer.key)) {
        final playerState = otherPlayer.value;
        final dashType = DashType.fromUserId(playerState.userId);
        final dash = Dash(
          playerId: playerState.userId,
          displayName: playerState.displayName.isNotBlank
              ? playerState.displayName
              : dashType.name,
          isMe: false,
          speed: game.gameMode.gameConfig.dashMoveSpeed,
        );
        add(dash);
        dash.position.setValues(playerState.lastKnownX, playerState.lastKnownY);
        _otherDashes[playerState.userId] = _OtherDashBundle(
          dash: dash,
          interpolator: RemoteDashInterpolator(),
        );
      }
    }
  }

  void _onNewEvent(MatchEvent event) {
    if (event is MatchSnapshotEvent) {
      _onSnapshot(event);
      return;
    }
    final senderId = event.sender?.userId;
    if (senderId == null) {
      // We don't care about events without a sender id (server events)
      return;
    }

    if (senderId == _cubit.state.currentAccount!.user.id) {
      // It's my own event
      return;
    }
    if (!_otherDashes.containsKey(senderId)) {
      // We don't have a dash for this player yet
      return;
    }
    switch (event) {
      case PlayerWillSpawnAtEvent():
        final player = _cubit.state.matchState!.players[event.sender!.userId]!;
        final spawnsAt = player.spawnsAgainAt;
        final spawnsAfter =
            spawnsAt.difference(DateTime.now()).inMilliseconds / 1000;
        _spawnPortalAndPlayer(
          playerId: event.sender!.userId,
          position: Vector2(player.lastKnownX, player.lastKnownY),
          spawnsAfter:
              spawnsAfter * FlappyDashRootComponent.gameSpeedMultiplier,
        );
        break;
      // Positions come from the snapshots; these only update the match state.
      case PlayerStartedEvent():
      case PlayerDiedEvent():
      case PlayerIsIdleEvent():
      case PlayerKickedFromTheLobbyEvent():
      case PlayerScoredEvent():
      case PlayerJoinedTheLobby():
      case MatchFinishedEvent():
      case MatchStartedEvent():
      case MatchPresencesUpdatedEvent():
      case MatchWaitingTimeIncreasedEvent():
      case MatchWelcomeEvent():
      case MatchPongEvent():
      case MatchSnapshotEvent():
        break;
    }
  }

  void _onSnapshot(MatchSnapshotEvent event) {
    final roster = _cubit.state.matchState?.roster;
    if (roster == null) {
      return;
    }
    for (final entry in event.snapshot.entries) {
      if (entry.rosterIndex >= roster.length) {
        continue;
      }
      final bundle = _otherDashes[roster[entry.rosterIndex]];
      bundle?.interpolator.addSnapshotEntry(entry);
    }
  }

  /// The world loops every [FlappyDashGame.worldWidth]. Of all the copies of
  /// [x], the one nearest to our own dash.
  double _nearestCopyX(double x) {
    final worldWidth = game.worldWidth;
    final myX = parent.myDashX;
    return x + ((myX - x) / worldWidth).round() * worldWidth;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final bundle in _otherDashes.values) {
      final interpolator = bundle.interpolator;
      interpolator.advance(dt);
      final state = interpolator.current();
      if (state == null) {
        continue;
      }
      bundle.dash.remotePlayingState = state.playingState;
      bundle.dash.setNetworkedState(_nearestCopyX(state.x), state.y, 0);
    }
  }

  void _spawnPortalAndPlayer({
    required String playerId,
    required Vector2 position,
    required double spawnsAfter,
  }) async {
    final dash = _otherDashes[playerId]!.dash;
    dash.scale = Vector2.all(0.0);

    // It's okay to show the other dash while it's idle after spawning,
    // Because we choose a correct place to spawn in the middle of pipes
    // But the first spawn, is random so we don't show the dash
    dash.visibleOnIdle = true;

    _cubit.addDebugMessage(
      DebugFunctionCallEvent(
        'MultiplayerController',
        '_spawnPortalAndPlayer - portal spawned',
        {
          'playerId': playerId.split('-')[0],
          'position': position.toStringWithMaxPrecision(2),
          'spawnsAfter': spawnsAfter.toStringAsFixed(2),
        },
      ),
    );
    add(
      SpawningPortal(
        position: Vector2(_nearestCopyX(position.x), position.y),
        size: Vector2.all(dash.size.x),
        color: AppColors.getDashColor(DashType.fromUserId(playerId))
            .darken(0.2),
        priority: -1,
        hideAfter: spawnsAfter - 0.5,
        onHide: () {
          _cubit.addDebugMessage(
            DebugFunctionCallEvent(
              'MultiplayerController',
              '_spawnPortalAndPlayer - portal hidden',
              {
                'playerId': playerId.split('-')[0],
                'dash.position': dash.position.toStringWithMaxPrecision(2),
                'dash.visibleOnIdle': dash.visibleOnIdle.toString(),
              },
            ),
          );
          dash.isNameVisible = false;
          dash.add(
            DashSpawnEffect(onComplete: () => dash.isNameVisible = true),
          );
        },
      ),
    );
  }

  @override
  void onRemove() {
    super.onRemove();
    _stateStreamSubscription.cancel();
    _eventStreamSubscription.cancel();
  }
}

class _OtherDashBundle {
  final Dash dash;
  final RemoteDashInterpolator interpolator;

  _OtherDashBundle({required this.dash, required this.interpolator});
}
