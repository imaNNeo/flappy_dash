part of 'leaderboard_cubit.dart';

class LeaderboardState with EquatableMixin {
  const LeaderboardState({
    this.leaderboardEntity,
    this.currentAccount,
  });

  final LeaderboardEntity? leaderboardEntity;
  final Account? currentAccount;

  LeaderboardState copyWith({
    LeaderboardEntity? leaderboardEntity,
    Account? currentAccount,
  }) =>
      LeaderboardState(
        leaderboardEntity: leaderboardEntity ?? this.leaderboardEntity,
        currentAccount: currentAccount ?? this.currentAccount,
      );

  @override
  List<Object?> get props => [
        leaderboardEntity,
        currentAccount,
      ];
}
