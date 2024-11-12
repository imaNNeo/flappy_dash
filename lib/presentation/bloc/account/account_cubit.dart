import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/app_constants.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(
    this._gameRepository,
  ) : super(const AccountState()) {
    _init();
  }

  final GameRepository _gameRepository;

  late StreamSubscription<Account> _accountUpdateStreamSubscription;

  void _init() async {
    _accountUpdateStreamSubscription =
        _gameRepository.getUserAccountUpdateStream().listen((account) {
      emit(state.copyWith(
        currentAccount: account,
      ));
    });
  }

  void updateUserDisplayName(String newUserDisplayName) async {
    await _gameRepository.updateUserDisplayName(newUserDisplayName);
  }

  @override
  Future<void> close() {
    _accountUpdateStreamSubscription.cancel();
    return super.close();
  }
}
