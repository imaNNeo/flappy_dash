import 'dart:async';
import 'dart:math';

import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/multiplayer_died_message.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit(this._audioHelper,
      this._gameRepository,) : super(const GameState());

  final AudioHelper _audioHelper;
  final GameRepository _gameRepository;

  Timer? _spawnTimer;

  void initialize(GameMode gameMode) {
    emit(const GameState().copyWith(
      gameMode: gameMode,
    ));
  }

  void startPlaying() {
    _audioHelper.playBackgroundAudio();
    emit(state.copyWith(
      currentPlayingState: PlayingState.playing,
      currentScore: 0,
    ));
  }

  void increaseScore() {
    _audioHelper.playScoreCollectSound();
    emit(state.copyWith(
      currentScore: state.currentScore + 1,
    ));
  }

  Future<void> gameOver() async {
    _audioHelper.stopBackgroundAudio();
    emit(state.copyWith(
      currentPlayingState: PlayingState.gameOver,
    ));

    final mode = state.gameMode;
    switch (mode) {
      case null || SinglePlayerGameMode():
        await _gameRepository.submitScore(state.currentScore);
        break;
      case MultiplayerGameMode():
        _spawnTimer ??= Timer.periodic(
          const Duration(milliseconds: 100),
          _respawnTimerTick,
        );
        final spawnsAfter = mode.gameConfig.spawnAgainAfterSeconds;


        emit(state.copyWith(
            spawnsAgainAt: DateTime.now().add(Duration(seconds: spawnsAfter)),
            spawnRemainingSeconds: spawnsAfter,
            multiplayerDiedMessage: _getRandomMultiplayerDiedMessage(),
        ));
        break;
    }
  }

  MultiplayerDiedMessage _getRandomMultiplayerDiedMessage() {
    List<MultiplayerDiedMessage> values;
    if (state.currentScore == 0) {
      values = MultiplayerDiedMessage.values.where((element) => element
          .onlyForZeroScore).toList();
    } else {
      values = MultiplayerDiedMessage.values.where((element) => !element
          .onlyForZeroScore).toList();
    }
    return values[Random().nextInt(values.length)];
  }

  // For single player game
  void restartGame() {
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
      currentScore: 0,
    ));
  }

  // For multiplayer game
  void continueGame() {
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
    ));
  }

  void stopPlaying() {
    _audioHelper.stopBackgroundAudio(immediately: true);
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
    ));
  }

  void _respawnTimerTick(_) {
    if (state.spawnsAgainAt == null) {
      return;
    }
    final diff = state.spawnsAgainAt!.difference(DateTime.now()).inSeconds;
    emit(state.copyWith(
      spawnRemainingSeconds: max(diff, 0),
    ));
  }

  @override
  Future<void> close() {
    _spawnTimer?.cancel();
    return super.close();
  }
}
