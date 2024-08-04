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
}
