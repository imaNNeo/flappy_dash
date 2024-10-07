part of 'multiplayer_cubit.dart';

class MultiplayerState with EquatableMixin {
  const MultiplayerState({
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
  });

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

  MultiplayerState copyWith({
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
  }) =>
      MultiplayerState(
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
      );

  @override
  List<Object?> get props => [
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
      ];
}
