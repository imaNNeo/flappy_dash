import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/match_diff_info_entity.dart';
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
    required super.priority,
    required this.myDash,
  });

  late StreamSubscription<MultiplayerState> _stateStreamSubscription;
  late StreamSubscription<(PlayerTickUpdateEvent, MultiplayerState)>
      _updateTickEventStreamSubscription;

  final Map<String, _OtherDashBundle> _otherDashes = {};

  MultiplayerState? _previousState;
  late MultiplayerCubit _cubit;

  String get myId => game.leaderboardCubit.state.currentAccount!.user.id;
  final Dash myDash;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _cubit = game.multiplayerCubit;
    _stateStreamSubscription = _cubit.stream.listen(_onNewState);
    _updateTickEventStreamSubscription =
        _cubit.matchUpdateEvents.listen(_onNewTickUpdateEvent);
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
        );
        add(dash);
        dash.position.x = playerState.x.toDouble();
        _otherDashes[playerState.userId] = _OtherDashBundle(
          dash: dash,
          playerState: playerState,
        );
      }
    }
  }

  void _onNewTickUpdateEvent((PlayerTickUpdateEvent, MultiplayerState) pair) {
    final tickUpdate = pair.$1;

    for (final diffInfo in tickUpdate.diff.diffInfo) {
      switch (diffInfo) {
        case MatchDiffInfoPlayerSpawned():
          // set the position
          final userId = diffInfo.userId;
          final isMe = userId == myId;
          final dash = isMe ? myDash : _otherDashes[userId]!.dash;
          dash.updateState(diffInfo.x, diffInfo.y, duration: 0.0);
          break;
        case MatchDiffInfoPlayerStarted():
          // Update the velocityX?
          break;
        case MatchDiffInfoPlayerJumped():
          // Update the velocityY?
          break;
        case MatchDiffInfoPlayerMoved():
          // Update the position
          final userId = diffInfo.userId;
          if (userId != myId) {
            final dash = _otherDashes[userId]!.dash;
            dash.updateState(diffInfo.x, diffInfo.y, duration: 0.0);
          }
          break;
        case MatchDiffInfoPlayerScored():
          // Nothing!
          break;
        case MatchDiffInfoPlayerSpawnTimeDecreased():
          // Nothing!
          break;
        case MatchDiffInfoPlayerDied():
          // Die animation at [diffInfo.x, diffInfo.y]

          // Spawn portal
          final userId = diffInfo.userId;
          if (userId != myId) {
            _spawnPortalAndPlayer(
              playerId: userId,
              position: Vector2(diffInfo.newX, diffInfo.newY),
              spawnsAfter: diffInfo.spawnsAgainIn,
            );
          }
          break;
      }
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
    _updateTickEventStreamSubscription.cancel();
  }
}

class _OtherDashBundle with EquatableMixin {
  final Dash dash;
  final PlayerState playerState;

  _OtherDashBundle({required this.dash, required this.playerState});

  @override
  List<Object?> get props => [dash, playerState];
}
