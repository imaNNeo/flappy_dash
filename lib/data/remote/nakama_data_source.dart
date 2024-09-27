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
      deviceId: deviceId,
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

  Future<List<User>> getUsers(List<String> userIds) => client.getUsers(
        session: _currentSession,
        ids: userIds,
      );

  Future<void> updateUserDisplayName(String newDisplayName) =>
      client.updateAccount(
        session: _currentSession,
        displayName: newDisplayName,
      );

  Future<LeaderboardRecordList> listLeaderboardRecordsAroundOwner(
      String leaderboardName) {
    return client.listLeaderboardRecordsAroundOwner(
      session: _currentSession,
      ownerId: _currentSession.userId,
      leaderboardName: leaderboardName,
    );
  }

  Future<String> getWaitingMatchId() async {
    final matchId = await client.rpc(
      session: _currentSession,
      id: 'get_waiting_match',
    );
    if (matchId == null) {
      throw Exception('Failed to get match id');
    }
    return matchId;
  }

}
