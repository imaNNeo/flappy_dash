import 'package:flappy_dash/domain/entities/leaderboard_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _init() async {
    await _refreshLeaderboard();
    await _refreshCurrentUserAccount();
  }

  Future<void> _refreshCurrentUserAccount() async {
    final account = await _gameRepository.getCurrentUserAccount();
    emit(state.copyWith(currentUserAccount: account));
  }

  Future<void> _refreshLeaderboard() async {
    final leaderboard = await _gameRepository.getLeaderboard();
    emit(state.copyWith(
      leaderboardEntity: leaderboard,
    ));
  }

  void updateUserDisplayName(String newUserDisplayName) async {
    await _gameRepository.updateUserDisplayName(newUserDisplayName);
    await _refreshLeaderboard();
    await _refreshCurrentUserAccount();
  }

  void onLeaderboardPageOpen() async {
    await _refreshLeaderboard();
  }
}
