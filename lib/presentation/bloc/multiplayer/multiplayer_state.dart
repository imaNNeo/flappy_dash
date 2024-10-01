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
    this.inLobbyPlayers = const [],
    this.joinedInLobby = false,
  });

  final String currentUserId;
  final String matchId;
  final bool joinMatchLoading;
  final String joinMatchError;
  final Match? currentMatch;
  final MatchState? matchState;
  final int? matchWaitingRemainingSeconds;
  final List<PlayerState> inLobbyPlayers;
  final bool joinedInLobby;

  MultiplayerState copyWith({
    String? currentUserId,
    String? matchId,
    bool? joinMatchLoading,
    String? joinMatchError,
    Match? currentMatch,
    MatchState? matchState,
    int? matchWaitingRemainingSeconds,
    List<PlayerState>? inLobbyPlayers,
    bool? joinedInLobby,
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
        inLobbyPlayers: inLobbyPlayers ?? this.inLobbyPlayers,
        joinedInLobby: joinedInLobby ?? this.joinedInLobby,
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
        inLobbyPlayers,
        joinedInLobby,
      ];
}
