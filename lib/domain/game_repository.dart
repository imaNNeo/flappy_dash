import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
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

  Completer<Session> currentSession = Completer();

  final _otherPlayerPositionDataStream =
      StreamController<(UserPresence, PositionData)>.broadcast();

  Stream<(UserPresence, PositionData)> get otherPlayerPositionDataStream =>
      _otherPlayerPositionDataStream.stream;

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

  Future<(Match, StreamSubscription)> initMainMatch() async {
    final (match, matchDataStream, matchPresenceStream) =
        await _nakamaDataSource.initMainMatch();

    final subscription = matchDataStream.listen((newData) {
      final operationType = OperationType.fromInt(newData.opCode);
      switch (operationType) {
        case OperationType.updatePosition:
          final positionData = PositionData.fromBytes(newData.data);
          _otherPlayerPositionDataStream.sink.add((
            newData.presence,
            positionData,
          ));
          break;
        default:
          break;
      }
    });

    return (match, subscription);
  }

  Future<void> updatePlayerPosition(
    String matchId,
    double x,
    double y,
  ) async {
    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    final utf8Bytes = utf8.encode(jsonData);

    await _nakamaDataSource.sendMatchData(
      matchId,
      OperationType.updatePosition.value,
      utf8Bytes,
    );
  }
}

enum OperationType {
  updatePosition(Int64.ONE),
  updateScore(Int64.TWO);

  final Int64 value;

  const OperationType(this.value);

  static OperationType fromInt(int value) => switch (value) {
        Int64.ONE => updatePosition,
        Int64.TWO => updateScore,
        _ => throw Exception('Unknown operation: $value'),
      };
}

class PositionData with EquatableMixin {
  final double x;
  final double y;

  PositionData({required this.x, required this.y});

  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory PositionData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return PositionData(
      x: json['x'],
      y: json['y'],
    );
  }

  @override
  List<Object?> get props => [x, y];
}
