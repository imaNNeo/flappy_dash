import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nakama/nakama.dart';

class NakamaDataSource {
  final client = getNakamaClient(
    host: kDebugMode ? 'localhost' : 'api.flappydash.com',
    ssl: !kDebugMode,
    serverKey: const String.fromEnvironment('NAKAMA_SERVER_KEY'),
    grpcPort: kDebugMode ? 8349 : 7349,
    httpPort: kDebugMode ? 8350 : 7350,
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

  // NakamaWebsocketClient? _websocketClient;
  // Completer<NakamaWebsocketClient>? _websocketClientCompleter;
  // Future<NakamaWebsocketClient> getWebsocketClient() async {
  //   if (_websocketClient != null) {
  //     return _websocketClient!;
  //   }
  //   if (_websocketClientCompleter != null) {
  //     return _websocketClientCompleter!.future;
  //   }
  //   _websocketClientCompleter = Completer();
  //   final websocketClient = NakamaWebsocketClient.init(
  //     host: kDebugMode ? 'localhost' : 'api.flappydash.com',
  //     ssl: !kDebugMode,
  //     port: kDebugMode ? 8350 : 7350,
  //     token: _currentSession.token,
  //     onError: (error) {
  //       _websocketClientCompleter!.completeError(error);
  //     },
  //     onDone: () {
  //       _websocketClientCompleter!.complete();
  //     },
  //   );
  //   return websocketClient;
  // }

  Future<String?> getWaitingMatchId() async {
    try {
      final websocketClient = NakamaWebsocketClient.init(
        host: kDebugMode ? 'localhost' : 'api.flappydash.com',
        ssl: !kDebugMode,
        port: kDebugMode ? 8350 : 7350,
        token: _currentSession.token,
      );

      final matchId = await client.rpc(
            session: _currentSession,
            id: 'get_waiting_match',
          );
      if (matchId == null) {
            return null;
          }

      print(_currentSession.token);
      //join match
      websocketClient.onMatchData.listen((onData) {
            if (onData.matchId != matchId) {
              return;
            }
            print('onMatchData: $onData');
          });
      websocketClient.onMatchPresence.listen((onData) {
            if (onData.matchId != matchId) {
              return;
            }
            print('onMatchPresence: $onData');
          });

      final match = await websocketClient.joinMatch(matchId);
      return matchId;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
