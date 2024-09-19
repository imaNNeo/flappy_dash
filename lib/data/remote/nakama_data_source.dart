import 'package:nakama/nakama.dart';

class NakamaDataSource {
  final client = getNakamaClient(
    host: 'api.flappydash.com',
    ssl: true,
    serverKey: const String.fromEnvironment('NAKAMA_SERVER_KEY'),
    grpcPort: 7349,
    // optional
    httpPort: 7350, // optional
  );

  late Session _currentSession;

  Future<Session> initSession(
    String deviceId,
  ) async {
    _currentSession = await client.authenticateDevice(
      deviceId: 'test-device-id',
      username: 'iman_neo',
    );
    return _currentSession;
  }

  Future<LeaderboardRecordList> getLeaderboard(String leaderboardName) async {
    final LeaderboardRecordList list = await client.listLeaderboardRecords(
      session: _currentSession,
      leaderboardName: leaderboardName,
    );
    return list;
  }

  Future<LeaderboardRecord> submitScore(
    int score,
    String leaderboardName,
  ) async {
    final response = await client.writeLeaderboardRecord(
      session: _currentSession,
      leaderboardName: leaderboardName,
      score: score,
    );

    return response;
  }

  String getCurrentUserId() => _currentSession.userId;

  Future<Account> getAccount() => client.getAccount(_currentSession);

  void updateUserName(String newUserName) {
    client.updateAccount(
      session: _currentSession,
      username: newUserName,
    );
  }
}
