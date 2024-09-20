part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.leaderboardEntity,
    this.currentUserAccount,
  });

  final int currentScore;
  final PlayingState currentPlayingState;
  final LeaderboardEntity? leaderboardEntity;
  final Account? currentUserAccount;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    LeaderboardEntity? leaderboardEntity,
    Account? currentUserAccount,
  }) =>
      GameState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        leaderboardEntity: leaderboardEntity ?? this.leaderboardEntity,
        currentUserAccount: currentUserAccount ?? this.currentUserAccount,
      );

  @override
  List<Object?> get props => [
        currentScore,
        currentPlayingState,
        leaderboardEntity,
        currentUserAccount,
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
