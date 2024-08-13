part of 'game_cubit.dart';

class GameState with EquatableMixin {
  GameState({
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.leaderboard,
    this.currentMatch,
    Map<String, OtherDashData> otherDashes = const {},
    this.currentUserId,
  })  : otherDashes = UnmodifiableMapView(otherDashes),
        gameConfig = const GameConfigEntity(
          pipesPosition: [0.2948985795081607, 0.8451437545490501, 0.06559718410732529, 0.8926572646248714, -0.3423664396962671, -0.19085421940133762, -0.634791641533947, 0.9394404905671276, -0.5524719622526493, 0.14531660775687283, 0.5771316134505757, -0.3030306512744627, 0.6269614050874155, 0.4898395553629833, 0.1737480246566221, 0.10211875650392432, 0.23567312601330737, 0.2730086215695988, 0.35986862542643583, -0.42335839560802735, -0.6879105796200027, -0.35615064651416106, 0.615470314001693, -0.03831183853290199, 0.8845366342106871, -0.992686699828091, 0.4594573344463282, 0.21742602886042195, 0.407971270816996, 0.6089028079152823, 0.06447963850266092, -0.5209944055287612, 0.7471048127871585, 0.6789660674164204, 0.8579302769868349, -0.6042222466796585, 0.31354485759925854, 0.954031679048343, -0.299435482470477, 0.8991628995316145, 0.19580259123494392, 0.8384533019689648],
          pipesPositionArea: 300.0,
          pipesDistance: 400.0,
          pipeWidth: 82.0,
          pipeHoleSize: 200,
        );

  final int currentScore;
  final PlayingState currentPlayingState;
  final LeaderboardRecordList? leaderboard;
  final Match? currentMatch;
  final Map<String, OtherDashData> otherDashes;
  final String? currentUserId;
  final GameConfigEntity? gameConfig;

  GameState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    ValueWrapper<LeaderboardRecordList>? leaderboard,
    ValueWrapper<Match>? currentMatch,
    Map<String, OtherDashData>? otherDashes,
    String? currentUserId,
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
        currentUserId: currentUserId ?? this.currentUserId,
      );

  @override
  List<Object?> get props => [
        currentScore,
        currentPlayingState,
        leaderboard,
        currentMatch,
        otherDashes,
        currentUserId,
        gameConfig,
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
