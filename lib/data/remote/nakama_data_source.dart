import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:nakama/nakama.dart';

import 'match_event_op_code.dart';

class NakamaDataSource {
  static const _host = kDebugMode ? 'localhost' : 'api.flappydash.com';
  static const _grpcPort = kDebugMode ? 8349 : 7349;
  static const _httpPort = kDebugMode ? 8350 : 7350;
  final client = getNakamaClient(
    host: _host,
    ssl: !kDebugMode,
    serverKey: const String.fromEnvironment('NAKAMA_SERVER_KEY'),
    grpcPort: _grpcPort,
    httpPort: _httpPort,
  );
  static const kIsolatesDisabled = kIsWeb || kIsWasm;

  String _makePayload(Map<String, dynamic> json) => kIsWeb || kIsWasm
      ? '"${jsonEncode(json).replaceAll('"', '\\"')}"'
      : jsonEncode(json);

  NakamaWebsocketClient _initWebsocketClient(String token) =>
      NakamaWebsocketClient.init(
        host: _host,
        ssl: !kDebugMode,
        port: _httpPort,
        token: token,
        onError: (error) {
          debugPrint('websocket error: $error');
        },
        onDone: () {
          debugPrint('websocket done');
        },
      );

  late NakamaWebsocketClient _websocketClient;

  late Session _currentSession;

  final _accountUpdateStreamController = StreamController<Account>.broadcast();

  Future<Session> initSession(
    String deviceId,
  ) async {
    _currentSession = await client.authenticateDevice(
      deviceId: deviceId,
    );
    _websocketClient = _initWebsocketClient(_currentSession.token);
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

  Future<Account> getAccount() async {
    final account = await client.getAccount(_currentSession);
    _accountUpdateStreamController.add(account);
    return account;
  }

  Stream<Account> getAccountUpdateStream() async* {
    yield await getAccount();
    yield* _accountUpdateStreamController.stream;
  }

  Future<List<User>> getUsers(List<String> userIds) => client.getUsers(
        session: _currentSession,
        ids: userIds,
      );

  Future<Account> updateUserDisplayName(String newDisplayName) async {
    await client.updateAccount(
      session: _currentSession,
      displayName: newDisplayName,
    );
    final account = await client.getAccount(_currentSession);
    _accountUpdateStreamController.add(account);
    return account;
  }

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

  Stream<MatchEvent> onMatchEvent(String matchId) async* {
    await for (final data in _websocketClient.onMatchData) {
      if (data.matchId != matchId) {
        return;
      }
      final index = MatchEventOpCode.values
          .indexWhere((element) => element.opCode == data.opCode);
      if (index == -1) {
        // opCode is not defined in the client
        debugPrint('Unknown event type with opCode: ${data.opCode}');
        continue;
      }
      final opCode = MatchEventOpCode.values[index];
      yield await _parseData(opCode, data);
    }
  }

  Future<MatchEvent> _parseData(MatchEventOpCode opCode, MatchData data) =>
      kIsolatesDisabled
          ? Future.value(opCode.parseIncomingEvent(data))
          : compute(opCode.parseIncomingEvent, data);

  Future<Match> joinMatch(String matchId) async {
    final match = await _websocketClient.joinMatch(matchId);
    if (match.matchId.isEmpty) {
      throw Exception('Failed to join match');
    }
    return match;
  }

  Future<void> leaveMatch(String matchId) =>
      _websocketClient.leaveMatch(matchId);

  void sendDispatchingEvent(String matchId, DispatchingMatchEvent event) async {
    if (!event.hideInDebugPanel) {
      debugPrint('Sending event: $event');
    }
    _websocketClient.sendMatchData(
      matchId: matchId,
      opCode: MatchEventOpCode.fromDispatchingEvent(event).opCode,
      data: kIsolatesDisabled
          ? event.toBytes()
          : await Isolate.run(() => event.toBytes()),
    );
  }

  Future<MatchResultEntity> getMatchResult(String matchId) async {
    final response = await client.rpc(
      session: _currentSession,
      id: 'get_match_result',
      payload: _makePayload({
        'matchId': matchId,
      }),
    );
    if (response == null || response.isBlank) {
      throw Exception('Failed to get match result');
    }
    return MatchResultEntity.fromJson(jsonDecode(response));
  }
}
