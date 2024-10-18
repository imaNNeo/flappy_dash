import 'dart:async';

import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';

part 'singleplayer_game_state.dart';

class SingleplayerGameCubit extends Cubit<SingleplayerGameState> {
  SingleplayerGameCubit(
    this._audioHelper,
    this._gameRepository,
  ) : super(const SingleplayerGameState());
  final AudioHelper _audioHelper;
  final GameRepository _gameRepository;

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
    await _gameRepository.submitScore(state.currentScore);
  }

  void restartGame() {
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
      currentScore: 0,
    ));
  }

  void stopPlaying() {
    _audioHelper.stopBackgroundAudio(immediately: true);
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
    ));
  }
}
