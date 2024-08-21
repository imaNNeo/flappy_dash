import 'dart:async';
import 'package:flappy_dash/data/local/device_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:nakama/nakama.dart';

import 'entities/game_event.dart';

class GameRepository {
  static const _mainLeaderboard = 'main_leaderboard';

  GameRepository(
    this._nakamaDataSource,
    this._deviceDataSource,
  );

  final NakamaDataSource _nakamaDataSource;
  final DeviceDataSource _deviceDataSource;

  Completer<Session> currentSession = Completer();

  Future<Session> initSession() async {
    final deviceId = await _deviceDataSource.getDeviceId();
    final session = await _nakamaDataSource.initSession(deviceId);
    currentSession.complete(session);
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

  Future<(RealtimeMatch, Stream<(UserPresence, GameEvent)>, Stream<MatchPresenceEvent>)>
      initMainMatch() async {
    final (match, matchDataStream, matchPresenceStream) =
        await _nakamaDataSource.initMainMatch();

    final stream1 = matchDataStream.map((newData) {
      return (
        newData.presence,
        GameEvent.fromBytes(newData.opCode, newData.data),
      );
    });
    return (match, stream1, matchPresenceStream);
  }

  Future<void> sendGameEvent(String matchId, GameEvent event) async {
    await _nakamaDataSource.sendMatchData(
      matchId,
      Int64(event.opCode),
      event.toBytes(),
    );
  }
}
