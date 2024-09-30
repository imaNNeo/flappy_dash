import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'multiplayer_state.dart';

class MultiplayerCubit extends Cubit<MultiplayerState> {
  MultiplayerCubit(
    this._multiplayerRepository,
  ) : super(const MultiplayerState()) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshRemainingTime();
    });
  }

  final MultiplayerRepository _multiplayerRepository;

  Timer? _timer;
  late StreamSubscription _matchEventsSubscription;

  void _refreshRemainingTime() {
    final remaining =
        state.matchState?.matchRunsAt.difference(DateTime.now()).inSeconds;
    emit(state.copyWith(
      matchWaitingRemainingSeconds:
          remaining != null ? max(remaining, 0) : remaining,
    ));
  }

  void joinMatch(String matchId) async {
    if (matchId != state.matchId) {
      // Reset the state
      emit(MultiplayerState(matchId: matchId));
    }

    if (state.joinMatchLoading) {
      return;
    }
    emit(state.copyWith(
      matchId: matchId,
      joinMatchLoading: true,
      joinMatchError: '',
    ));
    try {
      _matchEventsSubscription = _multiplayerRepository
          .onMatchEvent(state.matchId)
          .listen(_onMatchEvent);
      final match = await _multiplayerRepository.joinMatch(state.matchId);
      emit(state.copyWith(
        joinMatchLoading: false,
        currentMatch: match,
      ));
    } catch (e) {
      emit(state.copyWith(
        joinMatchLoading: false,
        joinMatchError: e.toString(),
      ));
    }
  }

  void _onMatchEvent(MatchEvent event) {
    final newState = switch (event) {
      MatchWelcomeEvent() => event.state,
      MatchWaitingTimeIncreasedEvent() => event.state,
      MatchPresencesUpdatedEvent() => event.state,
      MatchStartedEvent() => event.state,
      MatchFinishedEvent() => event.state,
      PlayerJoinedTheLobby() => event.state,
      PlayerStartedEvent() => event.state,
      PlayerJumpedEvent() => event.state,
      PlayerScoredEvent() => event.state,
      PlayerDiedEvent() => event.state,
      PlayerIsIdleEvent() => event.state,
      PlayerStartedAgainEvent() => event.state,
      PlayerKickedFromTheLobbyEvent() => event.state,
      PlayerCorrectPositionEvent() => event.state,
    };
    emit(state.copyWith(
      matchState: newState,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _matchEventsSubscription.cancel();
    return super.close();
  }
}
