import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flutter/cupertino.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._audioHelper,
  ) : super(const GameState());

  final AudioHelper _audioHelper;
  ValueNotifier<bool> restartNotifier = ValueNotifier(false);

  void startPlaying() {
    _audioHelper.playBackgroundMusic();
    emit(state.copyWith(
      playingState: PlayingState.playing,
    ));
  }

  void onScoreCollected() {
    _audioHelper.playScoreSound();
    emit(state.copyWith(
      currentScore: state.currentScore + 1,
      playingState: PlayingState.playing,
    ));
  }

  void gameOver() {
    _audioHelper.stopBackgroundMusic();
    emit(state.copyWith(
      playingState: PlayingState.gameOver,
    ));
  }

  void playAgain() {
    emit(const GameState());
    restartNotifier.value = true;
    restartNotifier.value = false;
  }
}
