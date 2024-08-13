import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
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

  late StreamSubscription _matchStreamSubscription;

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
    final (match, subscription) = await _gameRepository.initMainMatch();
    emit(state.copyWith(
      currentMatch: ValueWrapper(match),
    ));

    _matchStreamSubscription = subscription;
    _gameRepository.otherPlayerPositionDataStream.listen((newData) {
      final (presence, position) = newData;
      final newOtherDashes = Map.of(state.otherDashes);
      newOtherDashes[presence.userId] = OtherDashData(
        userId: presence.userId,
        x: position.x,
        y: position.y,
        userName: presence.username,
      );
      emit(state.copyWith(
        otherDashes: newOtherDashes,
      ));
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

  @override
  Future<void> close() async {
    super.close();
    _matchStreamSubscription.cancel();
  }
}
