import 'package:flappy_dash/data/local/device_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:nakama/nakama.dart';

class GameRepository {
  static const _mainLeaderboard = 'main_leaderboard';

  GameRepository(
    this._nakamaDataSource,
    this._deviceDataSource,
  );

  final NakamaDataSource _nakamaDataSource;
  final DeviceDataSource _deviceDataSource;

  Future<Session> initSession() async {
    final deviceId = await _deviceDataSource.getDeviceId();
    final session = await _nakamaDataSource.initSession(deviceId);
    print('session initialized, user: ${session.userId}, deviceId: $deviceId');
    return session;
  }

  Future<void> submitScore(int score) async {
    await _nakamaDataSource.submitScore(_mainLeaderboard, score);
  }

  Future<LeaderboardRecordList> getLeaderboard() async {
    return await _nakamaDataSource.getLeaderboard(
      _mainLeaderboard,
    );
  }
}
