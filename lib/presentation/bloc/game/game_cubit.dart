import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/other_dash_entity.dart';
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
  ) : super(GameState());

  final AudioHelper _audioHelper;
  final GameRepository _gameRepository;

  void onPageOpen() async {
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
    final (match, matchDataStream, matchPresenceStream) =
        await _gameRepository.initMainMatch();
    emit(state.copyWith(
      currentMatch: ValueWrapper(match),
    ));

    matchDataStream.listen((matchData) {
      matchData.data -> we need to convert it to x and y (utf8decode and jsonDecode)
    });
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

  void updatePlayerPosition(double x, double y) {
    if (state.currentMatch == null) {
      return;
    }
    _gameRepository.updatePlayerPosition(state.currentMatch!.matchId, x, y);
  }
}
