import 'dart:async';
import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
import 'package:flappy_dash/domain/entities/game_event.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
import 'package:flappy_dash/domain/extensions/map_extensions.dart';
import 'package:flappy_dash/domain/game_repository.dart';
import 'package:flappy_dash/presentation/audio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._audioHelper,
    this._gameRepository,
  ) : super(GameState());

  final AudioHelper _audioHelper;
  final GameRepository _gameRepository;

  late StreamSubscription _gameDataStreamSubscription;
  late StreamSubscription _matchPresenceStreamSubscription;

  final StreamController<(UserPresence, GameEvent)> _gameEventStreamController =
      StreamController<(UserPresence, GameEvent)>.broadcast();

  Stream<(UserPresence, GameEvent)> get otherDashesEventStream =>
      _gameEventStreamController.stream;

  void onPageOpen() async {
    emit(state.copyWith(
      currentUserId: (await _gameRepository.currentSession.future).userId,
    ));
    await _initMatch();
    await _refreshLeaderboard();
  }

  Future<void> _refreshLeaderboard() async {
    final leaderboard = await _gameRepository.getLeaderboard();
    emit(state.copyWith(
      leaderboard: ValueWrapper(leaderboard),
    ));
  }

  Future<void> _initMatch() async {
    final (match, gameEventStream, matchPresenceStream) =
        await _gameRepository.initMainMatch();
    emit(state.copyWith(
      currentMatch: ValueWrapper(match),
    ));
    _gameDataStreamSubscription = gameEventStream.listen(
      (data) {
        final (presence, event) = data;
        switch (event) {
          case StartGameEventData():
            final newOtherDashes = state.otherDashes.updateAndReturn(
              presence.userId,
              state.otherDashes[presence.userId]!.copyWith(
                playingState: OtherDashPlayingState.playing,
              ),
            );

            final newLastKnownPosition =
                state.otherDashesLastKnownPosition.updateAndReturn(
              presence.userId,
              Vector2(event.x, event.y),
            );
            emit(state.copyWith(
              otherDashes: newOtherDashes,
              otherDashesLastKnownPosition: newLastKnownPosition,
            ));
            break;
          case LetsTryAgainEventData():
            final newMap = state.otherDashes.updateAndReturn(
              presence.userId,
              state.otherDashes[presence.userId]!.copyWith(
                playingState: OtherDashPlayingState.idle,
              ),
            );
            emit(state.copyWith(otherDashes: newMap));
            break;
          case JumpEventData():
            final newLastKnownPosition =
                state.otherDashesLastKnownPosition.updateAndReturn(
              presence.userId,
              Vector2(event.x, event.y),
            );
            emit(state.copyWith(
              otherDashesLastKnownPosition: newLastKnownPosition,
            ));
            break;
          case CorrectPositionEventData():
            final newLastKnownPosition =
                state.otherDashesLastKnownPosition.updateAndReturn(
              presence.userId,
              Vector2(event.x, event.y),
            );
            emit(state.copyWith(
              otherDashesLastKnownPosition: newLastKnownPosition,
            ));
            break;
          case UpdateScoreEventData():
            final newMap = state.otherDashes.updateAndReturn(
              presence.userId,
              state.otherDashes[presence.userId]!.copyWith(
                score: event.score,
              ),
            );
            emit(state.copyWith(otherDashes: newMap));
            break;
          case LooseEventData():
            final newMap = state.otherDashes.updateAndReturn(
              presence.userId,
              state.otherDashes[presence.userId]!.copyWith(
                playingState: OtherDashPlayingState.gameOver,
              ),
            );

            final newLastKnownPosition =
                state.otherDashesLastKnownPosition.updateAndReturn(
              presence.userId,
              Vector2(event.x, event.y),
            );
            emit(state.copyWith(
              otherDashes: newMap,
              otherDashesLastKnownPosition: newLastKnownPosition,
            ));
            break;
        }
        _gameEventStreamController.add(data);
      },
    );

    _initPresencesInMatch(match);
    _matchPresenceStreamSubscription =
        matchPresenceStream.listen(_handlePresenceEvent);
  }

  void _initPresencesInMatch(RealtimeMatch match) {
    final newOtherDashes = Map.of(state.otherDashes);
    for (var element in match.presences) {
      if (element.userId == state.currentUserId) {
        continue;
      }
      newOtherDashes[element.userId] = OtherDashState(
        score: 0,
        name: element.username,
        playingState: OtherDashPlayingState.idle,
      );
    }
    emit(state.copyWith(otherDashes: newOtherDashes));
  }

  void _handlePresenceEvent(MatchPresenceEvent event) {
    final newOtherDashes = Map.of(state.otherDashes);
    for (var element in event.leaves) {
      if (element.userId == state.currentUserId) {
        continue;
      }
      newOtherDashes.remove(element.userId);
    }
    for (var element in event.joins) {
      if (element.userId == state.currentUserId) {
        continue;
      }
      newOtherDashes[element.userId] = OtherDashState(
        score: 0,
        name: element.username,
        playingState: OtherDashPlayingState.idle,
      );
    }
    emit(state.copyWith(otherDashes: newOtherDashes));
  }

  void updateMyPosition(Vector2 position) {
    emit(state.copyWith(
      myPosition: ValueWrapper(position),
    ));
  }

  void startPlaying() {
    _audioHelper.playBackgroundAudio();
    emit(state.copyWith(
      currentPlayingState: PlayingState.playing,
    ));
    _sendStartGameEvent(Vector2.zero());
  }

  void increaseScore() {
    _audioHelper.playScoreCollectSound();
    emit(state.copyWith(
      currentScore: state.currentScore + 1,
    ));
    _sendUpdateScoreEvent(state.currentScore);
  }

  void gameOver() async {
    _sendLooseEvent(state.myPosition!);
    _audioHelper.stopBackgroundAudio();
    emit(state.copyWith(
      currentPlayingState: PlayingState.gameOver,
    ));
    await _gameRepository.submitScore(state.currentScore);
    await _refreshLeaderboard();
  }

  void restartGame() {
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
    ));
    _sendLetsTryAgainEvent(Vector2.zero());
  }

  void _sendStartGameEvent(Vector2 position) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      StartGameEventData(x: position.x, y: position.y, score: 0),
    );
  }

  void _sendLetsTryAgainEvent(Vector2 position) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      LetsTryAgainEventData(x: position.x, y: position.y, score: 0),
    );
  }

  void sendJumpEvent(Vector2 position) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      JumpEventData(x: position.x, y: position.y),
    );
  }

  void sendCorrectPositionEvent(Vector2 position) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      CorrectPositionEventData(x: position.x, y: position.y),
    );
  }

  void _sendUpdateScoreEvent(int score) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      UpdateScoreEventData(score: score),
    );
  }

  void _sendLooseEvent(Vector2 position) {
    _gameRepository.sendGameEvent(
      state.currentMatch!.matchId,
      LooseEventData(x: position.x, y: position.y),
    );
  }

  @override
  Future<void> close() async {
    super.close();
    _gameDataStreamSubscription.cancel();
    _matchPresenceStreamSubscription.cancel();
    _gameEventStreamController.close();
  }
}
