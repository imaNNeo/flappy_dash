import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash/dash.dart';
import 'package:flappy_dash/presentation/component/flappy_dash_root_component.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/foundation.dart';

import 'dash/dash_spawn_effect.dart';
import 'dash/dash_spawn_portal.dart';

class MultiplayerController extends Component
    with ParentIsA<FlappyDashRootComponent>, HasGameRef<FlappyDashGame> {
  MultiplayerController({
    super.priority,
  });

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
    if (mapEquals(
        _previousState?.matchState?.players, state.matchState?.players)) {
      _onPlayersUpdated(state.matchState?.players);
    }

    _previousState = state;
  }

  void _onPlayersUpdated(Map<String, PlayerState>? players) {
    if (players == null) {
      _otherDashes
          .forEach((_, dashBundle) => dashBundle.dash.removeFromParent());
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
        dash.position.x = playerState.lastKnownX;
        _otherDashes[playerState.userId] = _OtherDashBundle(
          dash: dash,
          playerState: playerState,
        );
      }
    }
  }

  void _onNewEvent(MatchEvent event) {
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
    print('Controller received event: $event');
    switch (event) {
      case PlayerStartedEvent():
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updateState(
          event.dashX,
          event.dashY,
          event.dashVelocityY,
          duration: 0.0,
        );
        dash.jump();
        break;
      case PlayerJumpedEvent():
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updateState(
          event.dashX,
          event.dashY,
          event.dashVelocityY,
          duration: 0.0,
        );
        dash.jump();
        break;
      case PlayerDiedEvent():
        // Die animation? (state is automatically updated)
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updateState(
          event.dashX,
          event.dashY,
          event.dashVelocityY,
          duration: 0.0,
        );
        break;
      case PlayerWillSpawnAtEvent():
        final player = _cubit.state.matchState!.players[event.sender!.userId]!;
        final spawnsAt = player.spawnsAgainAt;
        final spawnsAfter =
            spawnsAt.difference(DateTime.now()).inMilliseconds / 1000;
        final newPos = Vector2(player.lastKnownX, player.lastKnownY);
        _spawnPortalAndPlayer(
          playerId: event.sender!.userId,
          position: newPos,
          spawnsAfter:
              spawnsAfter * FlappyDashRootComponent.gameSpeedMultiplier,
        );
        break;
      case PlayerCorrectPositionEvent():
        // We just mutate the position of the dash
        final dash = _otherDashes[event.sender!.userId]!.dash;
        if (_cubit.state.matchState!.players[event.sender!.userId]!.playingState
            .isNotPlaying) {
          return;
        }
        dash.updateState(
          event.dashX,
          event.dashY,
          event.dashVelocityY,
        );
        break;
      // We don't care about these events at the moment
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
        break;
    }
  }

  void _spawnPortalAndPlayer({
    required String playerId,
    required Vector2 position,
    required double spawnsAfter,
  }) async {
    final dash = _otherDashes[playerId]!.dash;
    dash.updateState(
      position.x,
      position.y,
      0.0,
      duration: 0.0,
    );
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
    add(SpawningPortal(
      position: position,
      size: Vector2.all(dash.size.x),
      color: AppColors.getDashColor(
        DashType.fromUserId(playerId),
      ).darken(0.2),
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
        dash.add(DashSpawnEffect(
          onComplete: () => dash.isNameVisible = true,
        ));
      },
    ));
  }

  @override
  void onRemove() {
    super.onRemove();
    _stateStreamSubscription.cancel();
    _eventStreamSubscription.cancel();
  }
}

class _OtherDashBundle with EquatableMixin {
  final Dash dash;
  final PlayerState playerState;

  _OtherDashBundle({required this.dash, required this.playerState});

  @override
  List<Object?> get props => [dash, playerState];
}
