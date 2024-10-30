part of 'match_result_cubit.dart';

class MatchResultState with EquatableMixin {
  const MatchResultState({
    required this.matchId,
    this.matchResult,
    this.isLoading = false,
    this.error = '',
    this.playAgainLoading = false,
    this.playAgainError = '',
    this.playAgainMatchId = '',
  });

  final String matchId;
  final MatchResultEntity? matchResult;
  final bool isLoading;
  final String error;
  final bool playAgainLoading;
  final String playAgainError;
  final String playAgainMatchId;

  // copyWith
  MatchResultState copyWith({
    String? matchId,
    MatchResultEntity? matchResult,
    bool? isLoading,
    String? error,
    bool? playAgainLoading,
    String? playAgainError,
    String? playAgainMatchId,
  }) =>
      MatchResultState(
        matchId: matchId ?? this.matchId,
        matchResult: matchResult ?? this.matchResult,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        playAgainLoading: playAgainLoading ?? this.playAgainLoading,
        playAgainError: playAgainError ?? this.playAgainError,
        playAgainMatchId: playAgainMatchId ?? this.playAgainMatchId,
      );

  @override
  List<Object?> get props => [
        matchId,
        matchResult,
        isLoading,
        error,
        playAgainLoading,
        playAgainError,
        playAgainMatchId,
      ];
}
