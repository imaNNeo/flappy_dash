import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
import 'package:flappy_dash/domain/game_repository.dart';
import 'package:flappy_dash/presentation/audio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._audioHelper,
    this._gameRepository,
  ) : super(const GameState());

  final AudioHelper _audioHelper;
  final GameRepository _gameRepository;

  void onPageOpen() async {
    await _refreshLeaderboard();
  }

  Future<void> _refreshLeaderboard() async {
    final leaderboard = await _gameRepository.getLeaderboard();
    emit(state.copyWith(
      leaderboard: ValueWrapper(leaderboard),
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

  void gameOver() async {
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
      currentScore: 0,
    ));
  }
}
