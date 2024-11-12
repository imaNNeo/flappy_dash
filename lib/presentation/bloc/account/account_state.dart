part of 'account_cubit.dart';

class AccountState with EquatableMixin {
  const AccountState({
    this.currentAccount,
  });

  final Account? currentAccount;

  bool get isDebugUser =>
      currentAccount != null &&
      AppConstants.debugUsernames.contains(currentAccount!.user.username);

  AccountState copyWith({
    Account? currentAccount,
  }) =>
      AccountState(
        currentAccount: currentAccount ?? this.currentAccount,
      );

  @override
  List<Object?> get props => [
        currentAccount,
      ];
}
