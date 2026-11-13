import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_overview_entity.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/entities/server_config_entity.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:nakama/nakama.dart';

import 'match_event_op_code.dart';

class NakamaDataSource {
  // Defaults: a local server in debug, production otherwise. Can be overridden
  // with e.g. --dart-define=NAKAMA_HOST=127.0.0.1 --dart-define=NAKAMA_SSL=false
  static const _host = String.fromEnvironment(
    'NAKAMA_HOST',
    defaultValue: kDebugMode ? 'localhost' : 'api.flappydash.com',
  );
  static const _ssl = bool.fromEnvironment(
    'NAKAMA_SSL',
    defaultValue: !kDebugMode,
  );
  static const _grpcPort = int.fromEnvironment(
    'NAKAMA_GRPC_PORT',
    defaultValue: kDebugMode ? 8349 : 7349,
  );
  static const _httpPort = int.fromEnvironment(
    'NAKAMA_HTTP_PORT',
    defaultValue: kDebugMode ? 8350 : 7350,
  );
  final client = getNakamaClient(
    host: _host,
    ssl: _ssl,
    serverKey: const String.fromEnvironment('NAKAMA_SERVER_KEY'),
    grpcPort: _grpcPort,
    httpPort: _httpPort,
  );
  static const kIsolatesDisabled = kIsWeb || kIsWasm;

  String _makePayload(Map<String, dynamic> json) => kIsWeb || kIsWasm
      ? '"${jsonEncode(json).replaceAll('"', '\\"')}"'
      : jsonEncode(json);

  late String _deviceId;

  late Session _currentSession;

  final _accountUpdateStreamController = StreamController<Account>.broadcast();

  /// Match data of every socket we open, so listeners survive reconnects.
  final _matchDataController = StreamController<MatchData>.broadcast();

  /// Emits after the socket dropped and a new one is connected.
  final _reconnectedController = StreamController<void>.broadcast();

  Stream<void> get onReconnected => _reconnectedController.stream;

  NakamaWebsocketClient? _websocketClient;
  StreamSubscription<MatchData>? _websocketMatchDataSubscription;
  Future<NakamaWebsocketClient>? _connectingWebsocket;
  int _websocketGeneration = 0;
  bool _hadConnection = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;

  Future<Session> initSession(String deviceId) async {
    _deviceId = deviceId;
    _currentSession = await client.authenticateDevice(deviceId: deviceId);
    await _ensureWebsocket();
    return _currentSession;
  }

  /// Sessions expire (2h on the server). The app can stay open far longer
  /// than that, so get a fresh session before it runs out.
  Future<Session> _ensureSession() async {
    final refreshBefore = DateTime.now().add(const Duration(minutes: 5));
    if (!_currentSession.hasExpired(refreshBefore)) {
      return _currentSession;
    }
    try {
      if (!_currentSession.isRefreshExpired) {
        _currentSession = await client.sessionRefresh(session: _currentSession);
        return _currentSession;
      }
    } catch (e) {
      debugPrint('session refresh failed, authenticating again: $e');
    }
    _currentSession = await client.authenticateDevice(deviceId: _deviceId);
    return _currentSession;
  }

  Future<NakamaWebsocketClient> _ensureWebsocket() {
    final current = _websocketClient;
    if (current != null) {
      return Future.value(current);
    }
    return _connectingWebsocket ??= _connectWebsocket().whenComplete(() {
      _connectingWebsocket = null;
    });
  }

  Future<NakamaWebsocketClient> _connectWebsocket() async {
    final session = await _ensureSession();
    final generation = ++_websocketGeneration;
    await _websocketMatchDataSubscription?.cancel();
    final socket = NakamaWebsocketClient.init(
      // A new key per connection: the package keeps one instance per key and
      // would otherwise hand back the dead socket.
      key: 'socket_$generation',
      host: _host,
      ssl: _ssl,
      port: _httpPort,
      token: session.token,
      onError: (error) {
        debugPrint('websocket error: $error');
      },
      onDone: () {
        debugPrint('websocket closed');
        _onWebsocketClosed(generation);
      },
    );
    _websocketMatchDataSubscription = socket.onMatchData.listen(
      _matchDataController.add,
    );
    _websocketClient = socket;
    if (_hadConnection) {
      _reconnectedController.add(null);
    }
    _hadConnection = true;
    _reconnectAttempt = 0;
    return socket;
  }

  void _onWebsocketClosed(int generation) {
    if (generation != _websocketGeneration) {
      return;
    }
    _websocketClient = null;
    _reconnectTimer?.cancel();
    final delaySeconds = 1 << _reconnectAttempt.clamp(0, 4);
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _ensureWebsocket().catchError((Object e) {
        debugPrint('websocket reconnect failed: $e');
        _onWebsocketClosed(_websocketGeneration);
        return Future<NakamaWebsocketClient>.error(e);
      }).ignore();
    });
  }

  Future<LeaderboardRecordList> getLeaderboard(String leaderboardName) async {
    final LeaderboardRecordList list = await client.listLeaderboardRecords(
      session: await _ensureSession(),
      leaderboardName: leaderboardName,
    );
    return list;
  }

  Future<LeaderboardRecord> submitScore(
    int score,
    String leaderboardName,
  ) async {
    final response = await client.writeLeaderboardRecord(
      session: await _ensureSession(),
      leaderboardName: leaderboardName,
      score: score,
    );

    return response;
  }

  String getCurrentUserId() => _currentSession.userId;

  Future<Account> getAccount() async {
    final account = await client.getAccount(await _ensureSession());
    _accountUpdateStreamController.add(account);
    return account;
  }

  Stream<Account> getAccountUpdateStream() async* {
    yield await getAccount();
    yield* _accountUpdateStreamController.stream;
  }

  Future<List<User>> getUsers(List<String> userIds) async =>
      client.getUsers(session: await _ensureSession(), ids: userIds);

  Future<Account> updateUserDisplayName(String newDisplayName) async {
    await client.updateAccount(
      session: await _ensureSession(),
      displayName: newDisplayName,
    );
    final account = await client.getAccount(await _ensureSession());
    _accountUpdateStreamController.add(account);
    return account;
  }

  Future<LeaderboardRecordList> listLeaderboardRecordsAroundOwner(
    String leaderboardName,
  ) async {
    return client.listLeaderboardRecordsAroundOwner(
      session: await _ensureSession(),
      ownerId: _currentSession.userId,
      leaderboardName: leaderboardName,
    );
  }

  Future<String> getWaitingMatchId() async {
    final matchId = await client.rpc(
      session: await _ensureSession(),
      id: 'get_waiting_match',
    );
    if (matchId == null || matchId.isBlank) {
      throw Exception('Failed to get match id');
    }
    return matchId;
  }

  Stream<MatchEvent> onMatchEvent(String matchId) async* {
    await for (final data in _matchDataController.stream) {
      if (data.matchId != matchId) {
        // Data of another match (e.g. the previous one); not for this listener.
        continue;
      }
      final index = MatchEventOpCode.values.indexWhere(
        (element) => element.opCode == data.opCode,
      );
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
    final socket = await _ensureWebsocket();
    final match = await socket.joinMatch(matchId);
    if (match.matchId.isEmpty) {
      throw Exception('Failed to join match');
    }
    return match;
  }

  Future<void> leaveMatch(String matchId) async {
    final socket = _websocketClient;
    if (socket == null) {
      // Disconnected: the server already removed us from the match.
      return;
    }
    await socket.leaveMatch(matchId);
  }

  void sendDispatchingEvent(String matchId, DispatchingMatchEvent event) async {
    if (!event.hideInDebugPanel) {
      debugPrint('Sending event: $event');
    }
    final socket = _websocketClient;
    if (socket == null) {
      // Disconnected; a reconnect is already scheduled.
      return;
    }
    socket.sendMatchData(
      matchId: matchId,
      opCode: MatchEventOpCode.fromDispatchingEvent(event).opCode,
      data: kIsolatesDisabled
          ? event.toBytes()
          : await Isolate.run(() => event.toBytes()),
    );
  }

  Future<MatchResultEntity> getMatchResult(String matchId) async {
    final response = await client.rpc(
      session: await _ensureSession(),
      id: 'get_match_result',
      payload: _makePayload({'matchId': matchId}),
    );
    if (response == null || response.isBlank) {
      throw Exception('Failed to get match result');
    }
    return MatchResultEntity.fromJson(jsonDecode(response));
  }

  Future<ServerConfigEntity> getServerConfig() async {
    final response = await client.rpc(
      session: await _ensureSession(),
      id: 'get_config',
    );
    if (response == null || response.isBlank) {
      throw Exception('Failed to get server config');
    }
    return ServerConfigEntity.fromJson(jsonDecode(response));
  }

  Future<MatchOverviewEntity> getLastMatchOverview() async {
    final response = await client.rpc(
      session: await _ensureSession(),
      id: 'get_last_match_overview',
    );
    if (response == null || response.isBlank) {
      throw Exception('Failed to get last match');
    }
    return MatchOverviewEntity.fromJson(jsonDecode(response));
  }
}
