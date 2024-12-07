import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/local_player_state.dart';
import 'package:flappy_dash/domain/entities/match_diff_info_entity.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_overview_entity.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flappy_dash/domain/entities/multiplayer_died_message.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
import 'package:flappy_dash/domain/extensions/map_extension.dart';
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
    this._audioHelper,
  ) : super(const MultiplayerState()) {
    _initialize();
  }

  final AudioHelper _audioHelper;
  final _matchGeneralEventsController =
      StreamController<MatchGeneralEvent>.broadcast();

  Stream<MatchGeneralEvent> get matchGeneralEvents =>
      _matchGeneralEventsController.stream;

  final _matchUpdateEventsController =
      StreamController<(PlayerTickUpdateEvent, MultiplayerState)>.broadcast();

  Stream<(PlayerTickUpdateEvent, MultiplayerState)> get matchUpdateEvents =>
      _matchUpdateEventsController.stream;

  void _initialize() async {
    final userId = await _gameRepository.getCurrentUserId();
    emit(state.copyWith(
      currentUserId: userId,
    ));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshRemainingTime();
      _refreshRespawnTimer();
      _tryToContinueGameAfterDied();
    });
    _listenToUserDisplayNameUpdates();
    _listenToDispatchingEvents();
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
  late StreamSubscription _matchGeneralEventsSubscription;
  late StreamSubscription _matchUpdateTickEventsSubscription;
  late StreamSubscription _dispatchingEventsSubscription;

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
      _multiplayerRepository.startListeningToMatchEvents(matchId);
      _matchGeneralEventsSubscription = _multiplayerRepository
          .generalMatchEvents
          .listen(_onGeneralMatchEvent);
      _matchUpdateTickEventsSubscription = _multiplayerRepository
          .updateTickEventsStream
          .listen(_onUpdateTickEvent);
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

  void _updateFullState(MatchState newState) {
    emit(state.copyWith(
      matchState: newState,
    ));
    _updateInLobbyState();
  }

  void _updateInLobbyState() {
    final matchState = state.matchState!;
    final me = matchState.players[state.currentUserId]!;
    final othersInLobby = matchState.players.values
        .where((player) =>
            player.isInLobby && player.userId != state.currentUserId)
        .toList();

    emit(state.copyWith(
      inLobbyPlayers: [
        if (me.isInLobby) me,
        ...othersInLobby,
      ],
      joinedInLobby: me.isInLobby,
    ));
  }

  void _onMatchStarted(MatchStartedEvent event) {
    final startingState = event.matchState;
    assert(startingState.currentPhase == MatchPhase.running);
    emit(state.copyWith(
      matchState: startingState,
      inLobbyPlayers: [],
      joinedInLobby: false,
      localPlayerState: ValueWrapper(
        startingState.players[state.currentUserId]!.toLocalPlayerState(),
      ),
    ));
  }

  void _onGeneralMatchEvent(MatchGeneralEvent event) {
    final phase = state.matchState?.currentPhase;
    _addDebugMessage(DebugIncomingEvent(event));
    switch (phase) {
      case null || MatchPhase.waitingForPlayers:
        switch (event) {
          case MatchWelcomeEvent():
            _updateFullState(event.matchState);
            break;
          case MatchWaitingTimeIncreasedEvent():
            emit(state.copyWith(
              matchState: state.matchState!.copyWith(
                matchRunsAt: event.newMatchRunsAt,
              ),
            ));
            break;
          case MatchPlayersJoined():
            final newPlayersMap = Map.of(state.matchState!.players);
            newPlayersMap.addAll(event.joinedPlayersInfo);
            final newMatchState = state.matchState!.copyWith(
              players: newPlayersMap,
            );
            emit(state.copyWith(
              matchState: newMatchState,
            ));
            _updateInLobbyState();
            break;
          case MatchPlayersLeft():
            final newPlayersMap = Map.of(state.matchState!.players);
            newPlayersMap.removeWhere(
                (key, value) => event.leftPlayerIds.any((id) => id == key));

            final newMatchState = state.matchState!.copyWith(
              players: newPlayersMap,
            );
            emit(state.copyWith(
              matchState: newMatchState,
            ));
            _updateInLobbyState();
            break;
          case MatchPlayerNameUpdatedEvent():
            final newPlayersMap = Map.of(state.matchState!.players);
            newPlayersMap[event.sender!.userId] =
                newPlayersMap[event.sender!.userId]!
                    .copyWith(displayName: event.newDisplayName);
            emit(state.copyWith(
              matchState: state.matchState!.copyWith(
                players: newPlayersMap,
              ),
              inLobbyPlayers: state.inLobbyPlayers
                  .map((player) => player.userId == event.sender!.userId
                      ? player.copyWith(displayName: event.newDisplayName)
                      : player)
                  .toList(),
            ));
            break;
          case PlayerJoinedTheLobby():
            final newPlayersMap = Map.of(state.matchState!.players);
            newPlayersMap[event.sender!.userId] = event.joinedPlayer;
            emit(state.copyWith(
              matchState: state.matchState!.copyWith(
                players: newPlayersMap,
              ),
            ));
            _updateInLobbyState();
            break;
          case PlayerKickedFromTheLobbyEvent():
            break;
          case MatchStartedEvent():
            _onMatchStarted(event);
            break;
          case _:
            // Do nothing
            break;
        }
        break;
      case MatchPhase.running:
        // We have _onUpdateTickEvent which handles all the game states
        if (event is MatchFinishedEvent) {
          _onMatchFinished(event.matchId);
        }
        break;
      case MatchPhase.finished:
        break;
    }
    _matchGeneralEventsController.add(event);
  }

  // delayed tick
  void _onUpdateTickEvent(PlayerTickUpdateEvent event) {
    emit(state.copyWith(
      matchState: _gerNewMatchStateBasedOnTickUpdate(event),
    ));
    _matchUpdateEventsController.add((event, state));
  }

  MatchState _gerNewMatchStateBasedOnTickUpdate(PlayerTickUpdateEvent event) {
    final diff = event.diff;
    var newState = state.matchState!.copyWith(
      playingTickNumber: diff.tickNumber,
    );
    for (final info in diff.diffInfo) {
      if (info is MatchDiffInfoPlayerSpawned) {
        print('Player spawned: ${info.userId}');
      }
      newState = switch (info) {
        MatchDiffInfoPlayerSpawned() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                playingState: PlayingState.idle,
                x: info.x,
                y: info.y,
              ),
            ),
          ),
        MatchDiffInfoPlayerStarted() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                playingState: info.playingState,
                velocityX: info.velocityX,
              ),
            ),
          ),
        MatchDiffInfoPlayerJumped() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                velocityY: info.velocityY,
              ),
            ),
          ),
        MatchDiffInfoPlayerMoved() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                x: info.x,
                y: info.y,
                velocityX: info.velocityX,
                velocityY: info.velocityY,
              ),
            ),
          ),
        MatchDiffInfoPlayerDied() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                playingState: PlayingState.gameOver,
                diedCount: info.diedCount,
                x: info.newX,
                y: info.newY,
                spawnsAgainIn: ValueWrapper(info.spawnsAgainIn),
              ),
            ),
          ),
        MatchDiffInfoPlayerScored() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(score: info.score),
            ),
          ),
        MatchDiffInfoPlayerSpawnTimeDecreased() => newState.copyWith(
            players: newState.players.updateAndReturn(
              info.userId,
              (player) => player.copyWith(
                spawnsAgainIn: ValueWrapper(info.spawnsAgainIn),
              ),
            ),
          ),
      };
    }
    return newState;
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

    _matchGeneralEventsSubscription.cancel();
    await _multiplayerRepository.leaveMatch(state.matchId);
  }

  void dispatchJumpEvent() {
    if (state.matchId.isBlank) {
      return;
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerJumpedEvent(),
    );
  }

  void increaseScore() {
    if (state.matchId.isBlank) {
      return;
    }
    _audioHelper.playScoreCollectSound();
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerScoredEvent(),
    );
    emit(state.copyWith(
      localPlayerState: ValueWrapper(
        state.localPlayerState!.copyWith(
          score: state.localPlayerState!.score + 1,
        ),
      ),
    ));
  }

  void playerDied() {
    if (state.matchId.isBlank) {
      return;
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerDiedEvent(),
    );
    emit(state.copyWith(
      localPlayerState: ValueWrapper(
        state.localPlayerState!.copyWith(
          playingState: PlayingState.gameOver,
          diedCount: state.localPlayerState!.diedCount + 1,
          spawnsAgainIn: ValueWrapper(state.matchState!.playerSpawnsAgainAfter),
        ),
      ),
      multiplayerDiedMessage: _getRandomMultiplayerDiedMessage(),
    ));
  }

  MultiplayerDiedMessage _getRandomMultiplayerDiedMessage() {
    List<MultiplayerDiedMessage> values;
    final diedCount = state.localPlayerState!.diedCount;
    if (state.currentScore == 0 && diedCount == 0) {
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
    final spawnAgainIn = state.localPlayerState?.spawnsAgainIn;
    if (spawnAgainIn == null) {
      return;
    }
    emit(state.copyWith(
      localPlayerState: ValueWrapper(
        state.localPlayerState!.copyWith(
          spawnsAgainIn: ValueWrapper(max(spawnAgainIn - 0.1, 0.0)),
        ),
      ),
    ));
  }

  void startPlaying() {
    if (state.matchId.isBlank) {
      return;
    }
    // First round
    final diedCount =
        state.matchState?.players[state.currentUserId]?.diedCount ?? 0;
    if (diedCount == 0) {
      _audioHelper.playBackgroundAudio();
    }
    _multiplayerRepository.sendDispatchingEvent(
      state.matchId,
      DispatchingPlayerStartedEvent(),
    );
    emit(state.copyWith(
      localPlayerState: ValueWrapper(
        state.localPlayerState!.copyWith(
          playingState: PlayingState.playing,
          velocityX: state.matchState!.playersInitialXSpeed,
        ),
      ),
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

  void _onMatchFinished(String matchId) {
    assert(state.matchId == matchId);
    emit(state.copyWith(
      matchState: state.matchState!.copyWith(
        currentPhase: MatchPhase.finished,
      ),
    ));
    _audioHelper.stopBackgroundAudio();
  }

  void _tryToContinueGameAfterDied() async {
    final spawnAgainIn = state.localPlayerState?.spawnsAgainIn;
    if (spawnAgainIn == null) {
      return;
    }

    if (state.matchId.isBlank) {
      emit(state.copyWith(
        localPlayerState: ValueWrapper(
          state.localPlayerState?.copyWith(
            spawnsAgainIn: ValueWrapper.nullValue(),
          ),
        ),
      ));
      return;
    }

    final isPlayerSpawnedInServer =
        state.matchState!.players[state.currentUserId]!.playingState.isIdle;
    if (spawnAgainIn <= 0 &&
        state.currentPlayingState.isGameOver &&
        isPlayerSpawnedInServer) {
      emit(state.copyWith(
        localPlayerState: ValueWrapper(
          state.localPlayerState!.copyWith(
            playingState: PlayingState.idle,
            spawnsAgainIn: ValueWrapper.nullValue(),
          ),
        ),
      ));
    }
  }

  void _listenToDispatchingEvents() {
    _dispatchingEventsSubscription =
        _multiplayerRepository.onEventDispatched().listen(
              (event) => _addDebugMessage(DebugDispatchingEvent(event)),
            );
  }

  void addDebugMessage(DebugMessage message) => _addDebugMessage(message);

  void _addDebugMessage(DebugMessage message) {
    final isHidden = switch (message) {
      DebugIncomingEvent() => message.event.hideInDebugPanel,
      DebugDispatchingEvent() => message.event.hideInDebugPanel,
      DebugFunctionCallEvent() => false,
    };
    if (isHidden) {
      return;
    }
    emit(state.copyWith(
      debugMessages: [
        ...state.debugMessages,
        message,
      ],
    ));
  }

  void refreshLastMatchOverview() async {
    final overview = await _multiplayerRepository.getLastMatchOverview();
    emit(state.copyWith(
      lastMatchOverview: ValueWrapper(overview),
    ));
  }

  void tappedOnAutoJumpArea() {
    if (state.countToTapForAutoJump <= 0) {
      return;
    }
    final countToTap = state.countToTapForAutoJump - 1;
    emit(state.copyWith(
      countToTapForAutoJump: countToTap,
    ));
    if (countToTap <= 0) {
      setAutoJumpEnabled(true);
    }
  }

  void setAutoJumpEnabled(bool enabled) {
    emit(state.copyWith(
      isCurrentPlayerAutoJump: enabled,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _matchGeneralEventsSubscription.cancel();
    _matchUpdateTickEventsSubscription.cancel();
    _dispatchingEventsSubscription.cancel();
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
