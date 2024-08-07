part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.leaderboard,
  });

  final int currentScore;
  final PlayingState currentPlayingState;
  final LeaderboardRecordList? leaderboard;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    ValueWrapper<LeaderboardRecordList>? leaderboard,
  }) =>
      GameState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        leaderboard: leaderboard != null ? leaderboard.value : this.leaderboard,
      );

  @override
  List<Object?> get props => [
        currentScore,
        currentPlayingState,
        leaderboard,
      ];
}

enum PlayingState {
  idle,
  playing,
  paused,
  gameOver;

  bool get isPlaying => this == PlayingState.playing;

  bool get isNotPlaying => !isPlaying;

  bool get isGameOver => this == PlayingState.gameOver;

  bool get isNotGameOver => !isGameOver;

  bool get isIdle => this == PlayingState.idle;

  bool get isPaused => this == PlayingState.paused;
}
