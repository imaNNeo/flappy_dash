part of 'multiplayer_cubit.dart';

class MultiplayerState with EquatableMixin {
  const MultiplayerState({
    this.gameMode = const MultiplayerGameMode(),
    this.currentScore = 0,
    this.currentPlayingState = PlayingState.idle,
    this.currentUserId = '',
    this.matchId = '',
    this.joinMatchLoading = false,
    this.joinMatchError = '',
    this.currentMatch,
    this.matchState,
    this.matchWaitingRemainingSeconds,
    this.matchPlayingRemainingSeconds,
    this.inLobbyPlayers = const [],
    this.joinedInLobby = false,
    this.currentAccount,
    this.spawnsAgainAt,
    this.spawnRemainingSeconds = 0,
    this.multiplayerDiedMessage,
    this.diedCount = 0,
    this.debugMessages = const [],
    this.lastMatchOverview,
    this.isCurrentPlayerAutoJump = false,
    this.countToTapForAutoJump = 10,
  });

  final MultiplayerGameMode gameMode;
  final int currentScore;
  final PlayingState currentPlayingState;
  final String currentUserId;
  final String matchId;
  final bool joinMatchLoading;
  final String joinMatchError;
  final Match? currentMatch;
  final MatchState? matchState;
  final int? matchWaitingRemainingSeconds;
  final int? matchPlayingRemainingSeconds;
  final List<PlayerState> inLobbyPlayers;
  final bool joinedInLobby;
  final Account? currentAccount;
  final DateTime? spawnsAgainAt;
  final int spawnRemainingSeconds;
  final MultiplayerDiedMessage? multiplayerDiedMessage;
  final int diedCount;
  final List<DebugMessage> debugMessages;
  final MatchOverviewEntity? lastMatchOverview;
  final bool isCurrentPlayerAutoJump;
  final int countToTapForAutoJump;

  MultiplayerState copyWith({
    int? currentScore,
    PlayingState? currentPlayingState,
    String? currentUserId,
    String? matchId,
    bool? joinMatchLoading,
    String? joinMatchError,
    Match? currentMatch,
    MatchState? matchState,
    int? matchWaitingRemainingSeconds,
    int? matchPlayingRemainingSeconds,
    List<PlayerState>? inLobbyPlayers,
    bool? joinedInLobby,
    Account? currentAccount,
    ValueWrapper<DateTime>? spawnsAgainAt,
    int? spawnRemainingSeconds,
    MultiplayerDiedMessage? multiplayerDiedMessage,
    int? diedCount,
    List<DebugMessage>? debugMessages,
    ValueWrapper<MatchOverviewEntity>? lastMatchOverview,
    bool? isCurrentPlayerAutoJump,
    int? countToTapForAutoJump,
  }) =>
      MultiplayerState(
        currentScore: currentScore ?? this.currentScore,
        currentPlayingState: currentPlayingState ?? this.currentPlayingState,
        currentUserId: currentUserId ?? this.currentUserId,
        matchId: matchId ?? this.matchId,
        joinMatchLoading: joinMatchLoading ?? this.joinMatchLoading,
        joinMatchError: joinMatchError ?? this.joinMatchError,
        currentMatch: currentMatch ?? this.currentMatch,
        matchState: matchState ?? this.matchState,
        matchWaitingRemainingSeconds:
            matchWaitingRemainingSeconds ?? this.matchWaitingRemainingSeconds,
        matchPlayingRemainingSeconds:
            matchPlayingRemainingSeconds ?? this.matchPlayingRemainingSeconds,
        inLobbyPlayers: inLobbyPlayers ?? this.inLobbyPlayers,
        joinedInLobby: joinedInLobby ?? this.joinedInLobby,
        currentAccount: currentAccount ?? this.currentAccount,
        spawnsAgainAt:
            spawnsAgainAt != null ? spawnsAgainAt.value : this.spawnsAgainAt,
        spawnRemainingSeconds:
            spawnRemainingSeconds ?? this.spawnRemainingSeconds,
        multiplayerDiedMessage:
            multiplayerDiedMessage ?? this.multiplayerDiedMessage,
        diedCount: diedCount ?? this.diedCount,
        debugMessages: debugMessages ?? this.debugMessages,
        lastMatchOverview: lastMatchOverview != null
            ? lastMatchOverview.value
            : this.lastMatchOverview,
        isCurrentPlayerAutoJump:
            isCurrentPlayerAutoJump ?? this.isCurrentPlayerAutoJump,
        countToTapForAutoJump:
            countToTapForAutoJump ?? this.countToTapForAutoJump,
      );

  @override
  List<Object?> get props => [
        gameMode,
        currentScore,
        currentPlayingState,
        currentUserId,
        matchId,
        joinMatchLoading,
        joinMatchError,
        currentMatch,
        matchState,
        matchWaitingRemainingSeconds,
        matchPlayingRemainingSeconds,
        inLobbyPlayers,
        joinedInLobby,
        currentAccount,
        spawnsAgainAt,
        spawnRemainingSeconds,
        multiplayerDiedMessage,
        diedCount,
        debugMessages,
        lastMatchOverview,
        isCurrentPlayerAutoJump,
        countToTapForAutoJump,
      ];
}
