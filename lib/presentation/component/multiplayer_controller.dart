import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash.dart';
import 'package:flappy_dash/presentation/component/flappy_dash_root_component.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/foundation.dart';

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
    switch (event) {
      case PlayerStartedEvent():
        break;
      case PlayerJumpedEvent():
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.jump();
        dash.updatePosition(event.dashX, event.dashY);
        break;
      case PlayerDiedEvent():
        // Die animation? (state is automatically updated)
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updatePosition(event.dashX, event.dashY);
        break;
      case PlayerIsIdleEvent():
        // Idle animation or style (state is automatically updated)
        // We just update the dash x position
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updatePosition(event.dashX, event.dashY);
        break;
      case PlayerCorrectPositionEvent():
        // We just mutate the position of the dash
        final dash = _otherDashes[event.sender!.userId]!.dash;
        dash.updatePosition(event.dashX, event.dashY);
        break;
      // We don't care about these events at the moment
      case PlayerKickedFromTheLobbyEvent():
      case PlayerScoredEvent():
      case PlayerJoinedTheLobby():
      case MatchFinishedEvent():
      case MatchStartedEvent():
      case MatchPresencesUpdatedEvent():
      case MatchWaitingTimeIncreasedEvent():
      case MatchWelcomeEvent():
        break;
    }
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
