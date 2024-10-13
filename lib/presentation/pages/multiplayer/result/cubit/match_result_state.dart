part of 'match_result_cubit.dart';

class MatchResultState with EquatableMixin {
  const MatchResultState({
    required this.matchId,
    this.matchResult,
    this.isLoading = false,
    this.error = '',
  });

  final String matchId;
  final MatchResultEntity? matchResult;
  final bool isLoading;
  final String error;

  // copyWith
  MatchResultState copyWith({
    String? matchId,
    MatchResultEntity? matchResult,
    bool? isLoading,
    String? error,
  }) =>
      MatchResultState(
        matchId: matchId ?? this.matchId,
        matchResult: matchResult ?? this.matchResult,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        matchId,
        matchResult,
        isLoading,
        error,
      ];
}
