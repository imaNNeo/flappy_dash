import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/leaderboard_entity.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nakama/nakama.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(
    this._gameRepository,
  ) : super(const LeaderboardState()) {
    _init();
  }

  final GameRepository _gameRepository;
  late final StreamSubscription<Account> _userAccountUpdateSubscription;

  void _init() {
    refreshLeaderboard();
    _listenToUserDisplayNameUpdates();
  }

  void _listenToUserDisplayNameUpdates() {
    _userAccountUpdateSubscription =
        _gameRepository.getUserAccountUpdateStream().listen((account) {
      final currentAccount = state.currentAccount;
      if (currentAccount != null &&
          currentAccount.user.displayName != account.user.displayName) {
        refreshLeaderboard();
      }
      emit(state.copyWith(currentAccount: account));
    });
  }

  Future<void> refreshLeaderboard() async {
    final leaderboard = await _gameRepository.getLeaderboard();
    emit(state.copyWith(
      leaderboardEntity: leaderboard,
    ));
  }

  void onLeaderboardPageOpen() async {
    await refreshLeaderboard();
  }

  @override
  Future<void> close() {
    _userAccountUpdateSubscription.cancel();
    return super.close();
  }
}
