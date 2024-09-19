import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:nakama/nakama.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._audioHelper,
    this._gameRepository,
  ) : super(const GameState()) {
    _init();
  }

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

  void gameOver() {
    _gameRepository.submitScore(state.currentScore);
    _audioHelper.stopBackgroundAudio();
    emit(state.copyWith(
      currentPlayingState: PlayingState.gameOver,
    ));
  }

  void restartGame() {
    emit(state.copyWith(
      currentPlayingState: PlayingState.idle,
      currentScore: 0,
    ));
  }

  void _init() async {
    await _updateLeaderboard();
    final account = await _gameRepository.getCurrentUserAccount();
    emit(state.copyWith(
      currentUserAccount: account,
    ));
  }

  Future<void> _updateLeaderboard() async {
    final leaderboard = await _gameRepository.getLeaderboard();
    print(leaderboard.records.map((e) => e.username));
    emit(state.copyWith(
      leaderboardRecordList: leaderboard,
    ));
  }

  void updateUserName(String newUserName) {
    _gameRepository.updateUserName(newUserName);
  }

  void refreshLeaderboard() async {
    await _updateLeaderboard();
  }
}
