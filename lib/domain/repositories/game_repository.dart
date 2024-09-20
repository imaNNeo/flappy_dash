import 'dart:async';

import 'package:flappy_dash/data/local/device_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:flappy_dash/domain/entities/leaderboard_entity.dart';
import 'package:nakama/nakama.dart';

class GameRepository {
  static const _mainLeaderboard = 'main_leaderboard';
  final DeviceDataSource _deviceDataSource;
  final NakamaDataSource _nakamaDataSource;

  final _initializationCompleter = Completer<void>();

  GameRepository(this._deviceDataSource, this._nakamaDataSource);

  Future<Session> initSession() async {
    try {
      final deviceId = await _deviceDataSource.getDeviceId();
      final session = await _nakamaDataSource.initSession(deviceId);
      _initializationCompleter.complete();
      return session;
    } catch (e) {
      _initializationCompleter.completeError(e);
      rethrow;
    }
  }

  Future<LeaderboardEntity> getLeaderboard() async {
    await _initializationCompleter.future;
    final recordList = await _nakamaDataSource.getLeaderboard(_mainLeaderboard);
    final ids = recordList.records.map((record) => record.ownerId!).toList();
    final users = await _nakamaDataSource.getUsers(ids);
    final usersMap = Map.fromEntries(
      users.map((user) => MapEntry(user.id, user)),
    );
    return LeaderboardEntity(
      recordList: recordList,
      userProfiles: usersMap,
    );
  }

  Future<String> getCurrentUserId() async {
    await _initializationCompleter.future;
    return _nakamaDataSource.getCurrentUserId();
  }

  Future<Account> getCurrentUserAccount() async {
    await _initializationCompleter.future;
    return _nakamaDataSource.getAccount();
  }

  Future<LeaderboardRecord> submitScore(int score) async {
    await _initializationCompleter.future;
    return _nakamaDataSource.submitScore(score, _mainLeaderboard);
  }

  Future<void> updateUserDisplayName(String newUserDisplayName) async {
    await _initializationCompleter.future;
    await _nakamaDataSource.updateUserDisplayName(newUserDisplayName);
  }
}
