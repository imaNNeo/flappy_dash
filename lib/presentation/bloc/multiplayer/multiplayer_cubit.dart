import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'multiplayer_state.dart';

class MultiplayerCubit extends Cubit<MultiplayerState> {
  MultiplayerCubit(
    this._multiplayerRepository,
    this._gameRepository,
  ) : super(const MultiplayerState()) {
    _initialize();
  }

  void _initialize() async {
    final userId = await _gameRepository.getCurrentUserId();
    emit(state.copyWith(
      currentUserId: userId,
    ));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshRemainingTime();
    });
    _listenToUserDisplayNameUpdates();
  }

  void _listenToUserDisplayNameUpdates() {
    _gameRepository.getUserAccountUpdateStream().listen((account) {
      final currentAccount = state.currentAccount;
      if (currentAccount != null &&
          currentAccount.user.displayName != account.user.displayName &&
          state.matchId.isNotBlank) {
        _multiplayerRepository.sendUserDisplayNameUpdatedEvent(state.matchId);
      }
      emit(state.copyWith(currentAccount: account));
    });
  }

  final MultiplayerRepository _multiplayerRepository;
  final GameRepository _gameRepository;

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
    final inLobby =
        newState.players.values.where((player) => player.isInLobby).toList();
    emit(state.copyWith(
      matchState: newState,
      inLobbyPlayers: inLobby,
      joinedInLobby:
          inLobby.any((player) => player.userId == state.currentUserId),
    ));
  }

  void joinLobby() {
    if (state.matchId.isBlank) {
      throw StateError('You are not allowed to join the lobby');
    }
    _multiplayerRepository.joinLobby(state.matchId);
  }

  void onLobbyClosed() async {
    if (state.matchId.isBlank) {
      return;
    }

    if (state.matchState?.currentPhase == MatchPhase.running) {
      return;
    }

    await _multiplayerRepository.leaveMatch(state.matchId);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _matchEventsSubscription.cancel();
    return super.close();
  }
}
