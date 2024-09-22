import 'package:flappy_dash/data/local/device_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';

class MultiplayerRepository {
  static const _mainLeaderboard = 'main_leaderboard';
  final DeviceDataSource _deviceDataSource;
  final NakamaDataSource _nakamaDataSource;

  MultiplayerRepository(
    this._deviceDataSource,
    this._nakamaDataSource,
  );

  Future<String> getWaitingMatchId() async {
    try {
      final matchId = await _nakamaDataSource.getWaitingMatchId();
      print('retrieved the match id: $matchId');
      return matchId ?? '';
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
