part of 'singleplayer_game_cubit.dart';

class SingleplayerGameState with EquatableMixin {
  const SingleplayerGameState({
    this.gameMode = const SinglePlayerGameMode(),
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
  });

  final SinglePlayerGameMode gameMode;
  final int currentScore;
  final PlayingState currentPlayingState;

  SingleplayerGameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
  }) =>
      SingleplayerGameState(
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
