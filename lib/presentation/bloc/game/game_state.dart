part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.gameMode,
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
  });

  final GameMode? gameMode;
  final int currentScore;
  final PlayingState currentPlayingState;

  GameState copyWith({
    GameMode? gameMode,
    int? currentScore,
    PlayingState? currentPlayingState,
  }) =>
      GameState(
        gameMode: gameMode ?? this.gameMode,
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
      );

  @override
  List<Object?> get props => [
        gameMode,
        currentScore,
        currentPlayingState,
      ];
}
