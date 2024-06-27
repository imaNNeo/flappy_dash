part of 'game_cubit.dart';

class GameState extends Equatable {
  const GameState({
    this.playingState = PlayingState.none,
    this.currentScore = 0,
  });

  final PlayingState playingState;
  final int currentScore;

  GameState copyWith({
    PlayingState? playingState,
    int? currentScore,
  }) {
    return GameState(
      playingState: playingState ?? this.playingState,
      currentScore: currentScore ?? this.currentScore,
    );
  }

  @override
  List<Object?> get props => [
        playingState,
        currentScore,
      ];
}

enum PlayingState {
  none,
  playing,
  gameOver;

  bool get isNone => this == PlayingState.none;

  bool get isPlaying => this == PlayingState.playing;

  bool get isGameOver => this == PlayingState.gameOver;
}
