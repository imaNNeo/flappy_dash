import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState());

  ValueNotifier<bool> restartNotifier = ValueNotifier(false);

  void startPlaying() {
    emit(state.copyWith(
      playingState: PlayingState.playing,
    ));
  }

  void onScoreCollected() {
    emit(state.copyWith(
      currentScore: state.currentScore + 1,
      playingState: PlayingState.playing,
    ));
  }

  void gameOver() {
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
