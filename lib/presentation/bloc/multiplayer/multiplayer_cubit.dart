import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flappy_dash/domain/entities/multiplayer_died_message.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'multiplayer_state.dart';

class MultiplayerCubit extends Cubit<MultiplayerState> {
  MultiplayerCubit(
    this._multiplayerRepository,
    this._gameRepository,
    this._audioHelper,
  ) : super(const MultiplayerState()) {
    _initialize();
  }

  final AudioHelper _audioHelper;
  final _matchEvents = StreamController<MatchEvent>.broadcast();

  Stream<MatchEvent> get matchEvents => _matchEvents.stream;

  void _initialize() async {
    final userId = await _gameRepository.getCurrentUserId();
    emit(state.copyWith(
      currentUserId: userId,
    ));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshRemainingTime();
      _refreshRespawnTimer();
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
    final waitingRemaining =
        state.matchState?.matchRunsAt.difference(DateTime.now()).inSeconds;
    final playingRemaining =
        state.matchState?.matchFinishesAt.difference(DateTime.now()).inSeconds;

    emit(state.copyWith(
      matchWaitingRemainingSeconds: waitingRemaining != null
          ? max(waitingRemaining, 0)
          : waitingRemaining,
      matchPlayingRemainingSeconds: playingRemaining != null
          ? max(playingRemaining, 0)
          : playingRemaining,
    ));
  }

  void joinMatch(String matchId) async {
    if (matchId != state.matchId) {
      // Reset the state
      emit(MultiplayerState(
        matchId: matchId,
        currentUserId: state.currentUserId,
        currentAccount: state.currentAccount,
      ));
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

  void _updateLobby(MatchState newState) {
    final me = newState.players[state.currentUserId]!;
    final othersInLobby = newState.players.values
        .where((player) =>
            player.isInLobby && player.userId != state.currentUserId)
        .toList();

    emit(state.copyWith(
      matchState: newState,
      inLobbyPlayers: [
        if (me.isInLobby) me,
        ...othersInLobby,
      ],
      joinedInLobby: me.isInLobby,
    ));
  }

  void _onMatchStarted(MatchState newState) {
    assert(newState.currentPhase == MatchPhase.running);
    emit(state.copyWith(
      matchState: newState,
      inLobbyPlayers: [],
      joinedInLobby: false,
      diedCount: 0,
    ));
  }

  void _onMatchEvent(MatchEvent event) {
    final phase = state.matchState?.currentPhase;
    debugPrint('Received event: $event in phase: $phase');
    switch (phase) {
      case null || MatchPhase.waitingForPlayers:
        switch (event) {
          case MatchWelcomeEvent():
          case MatchWaitingTimeIncreasedEvent():
          case MatchPresencesUpdatedEvent():
          case PlayerJoinedTheLobby():
          case PlayerKickedFromTheLobbyEvent():
            _updateLobby(event.state);
            break;
          case MatchStartedEvent():
            _onMatchStarted(event.state);
            break;

          case _:
            throw StateError('Invalid $event in this phase: $phase');
        }
        break;
      case MatchPhase.running:
        emit(state.copyWith(matchState: event.state));
        switch (event) {
          case MatchFinishedEvent():
            _onGameFinished();
            break;
          case _:
            break;
        }
        break;
      case MatchPhase.finished:
        break;
    }
    _matchEvents.add(event);
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

    _matchEventsSubscription.cancel();
    await _multiplayerRepository.leaveMatch(state.matchId);
  }

  void dispatchJumpEvent(double x, double y, double velocityY) {
    if (state.matchId.isBlank) {
      return;
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerJumpedEvent(
        x,
        y,
        velocityY,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void increaseScore(double x, double y, double velocityY) {
    if (state.matchId.isBlank) {
      return;
    }
    _audioHelper.playScoreCollectSound();
    emit(state.copyWith(
      currentScore: state.currentScore + 1,
    ));
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerScoredEvent(
        x,
        y,
        velocityY,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void playerDied(double x, double y, double velocityY) {
    if (state.matchId.isBlank) {
      return;
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerDiedEvent(
        x,
        y,
        velocityY,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
    final spawnsAfter = state.gameMode.gameConfig.spawnAgainAfterSeconds;
    emit(state.copyWith(
      currentPlayingState: PlayingState.gameOver,
      spawnsAgainAt: DateTime.now().add(Duration(seconds: spawnsAfter)),
      spawnRemainingSeconds: spawnsAfter,
      diedCount: state.diedCount + 1,
      multiplayerDiedMessage: _getRandomMultiplayerDiedMessage(),
    ));
  }

  MultiplayerDiedMessage _getRandomMultiplayerDiedMessage() {
    List<MultiplayerDiedMessage> values;
    if (state.currentScore == 0 && state.diedCount == 0) {
      values = MultiplayerDiedMessage.values
          .where((element) => element.onlyForZeroScore)
          .toList();
    } else {
      values = MultiplayerDiedMessage.values
          .where((element) => !element.onlyForZeroScore)
          .toList();
    }
    return values[Random().nextInt(values.length)];
  }

  void _refreshRespawnTimer() {
    if (state.spawnsAgainAt == null) {
      return;
    }
    final diff = state.spawnsAgainAt!.difference(DateTime.now()).inSeconds;
    emit(state.copyWith(
      spawnRemainingSeconds: max(diff, 0),
    ));
  }

  void startPlaying() {
    if (state.matchId.isBlank) {
      return;
    }

    // First round
    if (state.diedCount == 0) {
      _audioHelper.playBackgroundAudio();
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerStartedEvent(),
    );
    emit(state.copyWith(
      currentPlayingState: PlayingState.playing,
    ));
  }

  void stopPlaying(String matchId) {
    if (state.matchId.isBlank) {
      return;
    }
    if (state.matchId != matchId) {
      // This match might be already finished
      return;
    }
    _audioHelper.stopBackgroundAudio(immediately: true);
    _multiplayerRepository.leaveMatch(state.matchId);
  }

  void _onGameFinished() {
    _audioHelper.stopBackgroundAudio();
  }

  void continueGame() {
    if (state.matchId.isBlank) {
      return;
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerIsIdleEvent(),
    );
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
    ));
  }

  void dispatchCorrectPosition(double x, double y, double yVelocity) {
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerCorrectPositionEvent(
        x,
        y,
        yVelocity,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> close() {
    print('Closing multiplayer cubit');
    _timer?.cancel();
    _matchEventsSubscription.cancel();
    return super.close();
  }
}
