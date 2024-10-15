part of 'game_cubit.dart';

class GameState with EquatableMixin {
  const GameState({
    this.gameMode,
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.spawnsAgainAt,
    this.spawnRemainingSeconds = 0,
    this.multiplayerDiedMessage,
  });

  final GameMode? gameMode;
  final int currentScore;
  final PlayingState currentPlayingState;
  final DateTime? spawnsAgainAt;
  final int spawnRemainingSeconds;
  final MultiplayerDiedMessage? multiplayerDiedMessage;

  GameState copyWith({
    GameMode? gameMode,
    int? currentScore,
    PlayingState? currentPlayingState,
    DateTime? spawnsAgainAt,
    int? spawnRemainingSeconds,
    MultiplayerDiedMessage? multiplayerDiedMessage,
  }) =>
      GameState(
        gameMode: gameMode ?? this.gameMode,
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        spawnsAgainAt: spawnsAgainAt ?? this.spawnsAgainAt,
        spawnRemainingSeconds: spawnRemainingSeconds ?? this.spawnRemainingSeconds,
        multiplayerDiedMessage: multiplayerDiedMessage ?? this.multiplayerDiedMessage,
      );

  @override
  List<Object?> get props => [
        gameMode,
        currentScore,
        currentPlayingState,
        spawnsAgainAt,
        spawnRemainingSeconds,
        multiplayerDiedMessage,
      ];
}
