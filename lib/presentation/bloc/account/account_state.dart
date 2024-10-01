part of 'account_cubit.dart';

class AccountState with EquatableMixin {
  const AccountState({
    this.currentAccount,
  });

  final Account? currentAccount;

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
