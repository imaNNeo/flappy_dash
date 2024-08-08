part of 'game_cubit.dart';

class GameState with EquatableMixin {
  GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.leaderboard,
    this.currentMatch,
    Map<String, OtherDashData> otherDashes = const {},
  }) : otherDashes = UnmodifiableMapView(otherDashes);

  final int currentScore;
  final PlayingState currentPlayingState;
  final LeaderboardRecordList? leaderboard;
  final Match? currentMatch;
  final Map<String, OtherDashData> otherDashes;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    ValueWrapper<LeaderboardRecordList>? leaderboard,
    ValueWrapper<Match>? currentMatch,
    Map<String, OtherDashData>? otherDashes,
  }) =>
      GameState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        leaderboard: leaderboard != null ? leaderboard.value : this.leaderboard,
        currentMatch:
            currentMatch != null ? currentMatch.value : this.currentMatch,
        otherDashes: otherDashes != null
            ? UnmodifiableMapView(otherDashes)
            : this.otherDashes,
      );

  @override
  List<Object?> get props => [
        currentScore,
        currentPlayingState,
        leaderboard,
        currentMatch,
        otherDashes,
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
