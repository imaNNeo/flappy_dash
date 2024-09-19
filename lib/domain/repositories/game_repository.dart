import 'dart:async';

import 'package:flappy_dash/data/local/device_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:nakama/nakama.dart';

class GameRepository {
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

  Future<LeaderboardRecordList> getLeaderboard({
    String leaderboardName = 'main_leaderboard',
  }) async {
    await _initializationCompleter.future;
    return _nakamaDataSource.getLeaderboard(leaderboardName);
  }

  Future<String> getCurrentUserId() async {
    await _initializationCompleter.future;
    return _nakamaDataSource.getCurrentUserId();
  }

  Future<Account> getCurrentUserAccount() async {
    await _initializationCompleter.future;
    return _nakamaDataSource.getAccount();
  }

  Future<LeaderboardRecord> submitScore(
    int score, {
    String leaderboardName = 'main_leaderboard',
  }) async {
    await _initializationCompleter.future;
    return _nakamaDataSource.submitScore(score, leaderboardName);
  }

  void updateUserName(String newUserName) {
    _nakamaDataSource.updateUserName(newUserName);
  }
}
