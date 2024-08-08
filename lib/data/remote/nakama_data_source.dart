import 'dart:convert';

import 'package:nakama/nakama.dart';

class NakamaDataSource {
  final client = getNakamaClient(
    host: '188.166.38.155',
    ssl: false,
    serverKey: const String.fromEnvironment('NAKAMA_SERVER_KEY'),
    grpcPort: 7349,
    // optional
    httpPort: 7350, // optional
  );

  late Session currentSession;
  NakamaWebsocketClient? websocket;

  Future<Session> initSession(
    String deviceId,
  ) async {
    currentSession = await client.authenticateDevice(
      deviceId: deviceId,
    );

    // refresh if needed
    return currentSession;
  }

  Future<LeaderboardRecord> submitScore(String leaderboardName, int score) =>
      client.writeLeaderboardRecord(
        session: currentSession,
        leaderboardName: leaderboardName,
        score: score,
      );

  Future<LeaderboardRecordList> getLeaderboard(
    String leaderboardName,
  ) =>
      client.listLeaderboardRecords(
        session: currentSession,
        leaderboardName: leaderboardName,
      );

  Future<(Match, Stream<MatchData>, Stream<MatchPresenceEvent>)>
      initMainMatch() async {
    if (websocket != null) {
      await websocket!.close();
    }
    websocket = NakamaWebsocketClient.init(
      host: '188.166.38.155',
      ssl: false,
      token: currentSession.token,
    );
    return (
      await websocket!.createMatch('main_match'),
      websocket!.onMatchData,
      websocket!.onMatchPresence,
    );
  }

  Future<void> updatePlayerPositionOnMatch(
    String matchId,
    double x,
    double y,
  ) async {
    if (websocket == null) {
      await initMainMatch();
    }

    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    final utf8Bytes = utf8.encode(jsonData);
    websocket!.sendMatchData(
      matchId: matchId,
      opCode: Int64.ONE,
      data: utf8Bytes,
    );
  }
}
