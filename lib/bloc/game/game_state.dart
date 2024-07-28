part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.none,
  });

  final int currentScore;
  final PlayingState currentPlayingState;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
  }) =>
      GameState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
      );

  @override
  List<Object> get props => [
        currentScore,
        currentPlayingState,
      ];
}

enum PlayingState {
  none,
  playing,
  paused,
  gameOver,
}
