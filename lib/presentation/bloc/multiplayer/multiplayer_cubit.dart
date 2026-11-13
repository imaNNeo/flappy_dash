import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_overview_entity.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flappy_dash/domain/entities/multiplayer_died_message.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
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
    emit(state.copyWith(currentUserId: userId));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshRemainingTime();
      _refreshRespawnTimer();
      _tryToContinueGameAfterDied();
    });
    _listenToUserDisplayNameUpdates();
    _listenToDispatchingEvents();
    _reconnectedSubscription = _multiplayerRepository.onReconnected.listen(
      (_) => _rejoinAfterReconnect(),
    );
  }

  /// The server drops us from the match when the socket closes. Join again
  /// (the server keeps our score) and get back into the lobby if we were in it.
  void _rejoinAfterReconnect() async {
    final matchId = state.matchId;
    if (matchId.isBlank || state.currentMatch == null) {
      return;
    }
    if (state.matchState?.currentPhase == MatchPhase.finished) {
      return;
    }
    final wasInLobby = state.joinedInLobby;
    try {
      final match = await _multiplayerRepository.joinMatch(matchId);
      if (isClosed || state.matchId != matchId) {
        return;
      }
      emit(state.copyWith(currentMatch: match));
      if (wasInLobby && state.matchState?.currentPhase != MatchPhase.running) {
        _multiplayerRepository.joinLobby(matchId);
      }
    } catch (e) {
      _addDebugMessage(
        DebugFunctionCallEvent(
          'MultiplayerCubit',
          'rejoinAfterReconnect failed',
          {'error': e.toString()},
        ),
      );
    }
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
  StreamSubscription? _matchEventsSubscription;
  late StreamSubscription _dispatchingEventsSubscription;
  late StreamSubscription _reconnectedSubscription;

  void _refreshRemainingTime() {
    final matchState = state.matchState;
    final now = DateTime.now();
    final waitingRemaining = matchState?.matchRunsAt.difference(now).inSeconds;
    final playingRemaining = matchState?.matchFinishesAt
        .difference(now)
        .inSeconds;
    final newWaiting = waitingRemaining != null
        ? max(waitingRemaining, 0)
        : waitingRemaining;
    final newPlaying = playingRemaining != null
        ? max(playingRemaining, 0)
        : playingRemaining;

    // This runs 10 times a second; only emit when a value really changed, so
    // we skip building and comparing a whole new state for nothing.
    if (newWaiting == state.matchWaitingRemainingSeconds &&
        newPlaying == state.matchPlayingRemainingSeconds) {
      return;
    }
    emit(
      state.copyWith(
        matchWaitingRemainingSeconds: newWaiting,
        matchPlayingRemainingSeconds: newPlaying,
      ),
    );
  }

  void joinMatch(String matchId) async {
    if (matchId != state.matchId) {
      // Reset the state
      emit(
        MultiplayerState(
          matchId: matchId,
          currentUserId: state.currentUserId,
          currentAccount: state.currentAccount,
        ),
      );
    }

    if (state.joinMatchLoading) {
      return;
    }
    emit(
      state.copyWith(
        matchId: matchId,
        joinMatchLoading: true,
        joinMatchError: '',
      ),
    );
    try {
      await _listenAndJoin(state.matchId);
    } catch (e) {
      // The match may have started or ended in the meantime (e.g. an old
      // lobby link). Fall back to the match that is waiting for players now.
      try {
        final waitingMatchId = await _multiplayerRepository.getWaitingMatchId();
        if (waitingMatchId == state.matchId) {
          rethrow;
        }
        emit(
          MultiplayerState(
            matchId: waitingMatchId,
            currentUserId: state.currentUserId,
            currentAccount: state.currentAccount,
            joinMatchLoading: true,
          ),
        );
        await _listenAndJoin(waitingMatchId);
      } catch (_) {
        emit(
          state.copyWith(joinMatchLoading: false, joinMatchError: e.toString()),
        );
      }
    }
  }

  Future<void> _listenAndJoin(String matchId) async {
    await _matchEventsSubscription?.cancel();
    _matchEventsSubscription = _multiplayerRepository
        .onMatchEvent(matchId)
        .listen(_onMatchEvent);
    final match = await _multiplayerRepository.joinMatch(matchId);
    emit(state.copyWith(joinMatchLoading: false, currentMatch: match));
  }

  void _updateLobby(MatchState newState) {
    final me = newState.players[state.currentUserId]!;
    final othersInLobby = newState.players.values
        .where(
          (player) => player.isInLobby && player.userId != state.currentUserId,
        )
        .toList();

    emit(
      state.copyWith(
        matchState: newState,
        inLobbyPlayers: [if (me.isInLobby) me, ...othersInLobby],
        joinedInLobby: me.isInLobby,
      ),
    );
  }

  void _onMatchStarted(MatchState newState) {
    assert(newState.currentPhase == MatchPhase.running);
    emit(
      state.copyWith(
        matchState: newState,
        inLobbyPlayers: [],
        joinedInLobby: false,
        diedCount: 0,
      ),
    );
  }

  void _onMatchEvent(MatchEvent event) {
    final phase = state.matchState?.currentPhase;
    final debugMessage = DebugIncomingEvent(event);
    // While the match runs, nearly every event carries a new match state.
    // Emit it together with the debug log entry: one state change per event
    // instead of two for every listener and widget to react to.
    final mergeWithMatchState =
        phase == MatchPhase.running && event is HasMatchState;
    if (!mergeWithMatchState) {
      _addDebugMessage(debugMessage);
    }
    switch (phase) {
      case null || MatchPhase.waitingForPlayers:
        switch (event) {
          case MatchWelcomeEvent():
          case MatchWaitingTimeIncreasedEvent():
          case MatchPresencesUpdatedEvent():
          case PlayerJoinedTheLobby():
          case PlayerKickedFromTheLobbyEvent():
            if (event is HasMatchState) {
              _updateLobby((event as HasMatchState).state);
            }
            break;
          case MatchStartedEvent():
            _onMatchStarted(event.state);
            break;
          case _:
            // Do nothing
            break;
        }
        break;
      case MatchPhase.running:
        if (mergeWithMatchState) {
          emit(
            state.copyWith(
              matchState: (event as HasMatchState).state,
              debugMessages: _debugMessagesWith(debugMessage),
            ),
          );
        }
        switch (event) {
          case MatchFinishedEvent():
            _onGameFinished();
            break;
          case PlayerWillSpawnAtEvent():
            if (state.currentUserId == event.sender!.userId) {
              final spawnsAt = state
                  .matchState!
                  .players[event.sender!.userId]!
                  .spawnsAgainAt;
              final spawnsAfter = spawnsAt.difference(DateTime.now()).inSeconds;

              emit(
                state.copyWith(
                  spawnsAgainAt: ValueWrapper(spawnsAt),
                  spawnRemainingSeconds: spawnsAfter,
                ),
              );
            }
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

    _matchEventsSubscription?.cancel();
    _matchEventsSubscription = null;
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
    emit(state.copyWith(currentScore: state.currentScore + 1));
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
    final pipesDistance = state.gameMode.gameConfig.pipesDistance;
    final spawnOnPipeIndex = Random().nextInt(
      state.matchState!.pipesPositions.length - 1,
    );
    final newX = ((spawnOnPipeIndex + 1) * pipesDistance).toDouble();
    final newY =
        state.matchState!.pipesPositions[spawnOnPipeIndex] *
        state.gameMode.gameConfig.pipesPositionArea;
    _addDebugMessage(
      DebugFunctionCallEvent('MultiplayerCubit', 'playerDied', {
        'x': x.toStringAsFixed(2),
        'y': y.toStringAsFixed(2),
        'newPosPipeIndex': spawnOnPipeIndex.toString(),
        'newX': newX.toStringAsFixed(2),
        'newY': newY.toStringAsFixed(2),
      }),
    );
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerDiedEvent(
        x,
        y,
        velocityY,
        DateTime.now().millisecondsSinceEpoch,
        newX,
        newY,
      ),
    );
    emit(
      state.copyWith(
        currentPlayingState: PlayingState.gameOver,
        diedCount: state.diedCount + 1,
        multiplayerDiedMessage: _getRandomMultiplayerDiedMessage(),
      ),
    );
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
    final remaining = max(diff, 0);
    if (remaining == state.spawnRemainingSeconds) {
      return;
    }
    emit(state.copyWith(spawnRemainingSeconds: remaining));
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
    emit(state.copyWith(currentPlayingState: PlayingState.playing));
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

  void _tryToContinueGameAfterDied() async {
    if (state.spawnsAgainAt == null) {
      return;
    }

    if (state.matchId.isBlank) {
      emit(state.copyWith(spawnsAgainAt: ValueWrapper.nullValue()));
      return;
    }

    final secondsLeft = state.spawnsAgainAt!
        .difference(DateTime.now())
        .inSeconds;

    if (secondsLeft <= 0 && state.currentPlayingState.isGameOver) {
      emit(
        state.copyWith(
          spawnsAgainAt: ValueWrapper.nullValue(),
          currentPlayingState: PlayingState.idle,
        ),
      );
    }
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

  void dispatchIdleEvent(double x, double y) {
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerIsIdleEvent(x, y, DateTime.now().millisecondsSinceEpoch),
    );
  }

  void _listenToDispatchingEvents() {
    _dispatchingEventsSubscription = _multiplayerRepository
        .onEventDispatched()
        .listen((event) => _addDebugMessage(DebugDispatchingEvent(event)));
  }

  void addDebugMessage(DebugMessage message) => _addDebugMessage(message);

  void _addDebugMessage(DebugMessage message) {
    final debugMessages = _debugMessagesWith(message);
    if (identical(debugMessages, state.debugMessages)) {
      return;
    }
    emit(state.copyWith(debugMessages: debugMessages));
  }

  DebugMessageLog _debugMessagesWith(DebugMessage message) {
    final isHidden = switch (message) {
      DebugIncomingEvent() => message.event.hideInDebugPanel,
      DebugDispatchingEvent() => message.event.hideInDebugPanel,
      DebugFunctionCallEvent() => false,
    };
    if (isHidden) {
      return state.debugMessages;
    }
    return state.debugMessages.add(message);
  }

  void refreshLastMatchOverview() async {
    try {
      final overview = await _multiplayerRepository.getLastMatchOverview();
      emit(state.copyWith(lastMatchOverview: ValueWrapper(overview)));
    } catch (e) {
      // No finished match yet (or the server is unreachable); the lobby
      // simply doesn't show the last winner then.
      debugPrint('Failed to load the last match overview: $e');
    }
  }

  void tappedOnAutoJumpArea() {
    if (state.countToTapForAutoJump <= 0) {
      return;
    }
    final countToTap = state.countToTapForAutoJump - 1;
    emit(state.copyWith(countToTapForAutoJump: countToTap));
    if (countToTap <= 0) {
      setAutoJumpEnabled(true);
    }
  }

  void setAutoJumpEnabled(bool enabled) {
    emit(state.copyWith(isCurrentPlayerAutoJump: enabled));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _matchEventsSubscription?.cancel();
    _dispatchingEventsSubscription.cancel();
    _reconnectedSubscription.cancel();

    return super.close();
  }

  void onGamePageOpened(String matchId) async {
    assert(matchId == state.matchId);
    if (state.isCurrentPlayerAutoJump) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!isClosed) {
        startPlaying();
      }
    }
  }
}
