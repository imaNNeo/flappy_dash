part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.leaderboardRecordList,
    this.currentUserAccount,
  });

  final int currentScore;
  final PlayingState currentPlayingState;
  final LeaderboardRecordList? leaderboardRecordList;
  final Account? currentUserAccount;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    LeaderboardRecordList? leaderboardRecordList,
    Account? currentUserAccount,
  }) =>
      GameState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        leaderboardRecordList:
            leaderboardRecordList ?? this.leaderboardRecordList,
        currentUserAccount: currentUserAccount ?? this.currentUserAccount,
      );

  @override
  List<Object?> get props => [
        currentScore,
        currentPlayingState,
        leaderboardRecordList,
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
