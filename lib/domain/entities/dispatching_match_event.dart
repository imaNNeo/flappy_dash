import 'dart:convert';

List<int> _jsonToData(Map<String, dynamic> json) =>
    utf8.encode(jsonEncode(json));

sealed class DispatchingMatchEvent {
  const DispatchingMatchEvent();

  List<int> toBytes();

  String debugExtraInfo();

  bool get hideInDebugPanel => false;

  String get debugName;
}

class DispatchingPlayerJoinedLobbyEvent extends DispatchingMatchEvent {
  DispatchingPlayerJoinedLobbyEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerJoinedLobby';
}

class DispatchingPlayerStartedEvent extends DispatchingMatchEvent {
  DispatchingPlayerStartedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerStarted';
}

class DispatchingPlayerJumpedEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;
  final double velocityY;
  final int timestamp;

  DispatchingPlayerJumpedEvent(
    this.positionX,
    this.positionY,
    this.velocityY,
    this.timestamp,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
        'velocityY': velocityY,
        'timestamp': timestamp,
      });

  @override
  String debugExtraInfo() =>
      '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';

  @override
  String get debugName => 'PlayerJumped';
}

class DispatchingPlayerScoredEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;
  final double velocityY;
  final int timestamp;

  DispatchingPlayerScoredEvent(
    this.positionX,
    this.positionY,
    this.velocityY,
    this.timestamp,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
        'velocityY': velocityY,
        'timestamp': timestamp,
      });

  @override
  String debugExtraInfo() =>
      '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';

  @override
  String get debugName => 'PlayerScored';
}

class DispatchingPlayerDiedEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;
  final double velocityY;
  final int timestamp;
  final double newPositionX;
  final double newPositionY;

  DispatchingPlayerDiedEvent(
    this.positionX,
    this.positionY,
    this.velocityY,
    this.timestamp,
    this.newPositionX,
    this.newPositionY,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
        'velocityY': velocityY,
        'timestamp': timestamp,
        'newPositionX': newPositionX,
        'newPositionY': newPositionY,
      });

  @override
  String debugExtraInfo() =>
      '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)}) -> (${newPositionX.toStringAsFixed(1)}, ${newPositionY.toStringAsFixed(1)})';

  @override
  String get debugName => 'PlayerDied';
}

class DispatchingPlayerIsIdleEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;
  final int timestamp;

  DispatchingPlayerIsIdleEvent(
    this.positionX,
    this.positionY,
    this.timestamp,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
        'timestamp': timestamp,
      });

  @override
  String debugExtraInfo() =>
      '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';

  @override
  String get debugName => 'PlayerIsIdle';
}

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'UserDisplayNameUpdated';
}

class DispatchingPlayerCorrectPositionEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;
  final double velocityY;
  final int timestamp;

  DispatchingPlayerCorrectPositionEvent(
    this.positionX,
    this.positionY,
    this.velocityY,
    this.timestamp,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
        'velocityY': velocityY,
        'timestamp': timestamp,
      });

  @override
  String debugExtraInfo() =>
      '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';

  @override
  String get debugName => 'PlayerCorrectPosition';
}

class DispatchingPingEvent extends DispatchingMatchEvent {
  final int previousPing;
  final String pingId;
  final DateTime sentAt;

  DispatchingPingEvent(
    this.previousPing,
    this.pingId,
    this.sentAt,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'previousPing': previousPing,
        'pingId': pingId,
        'sentAt': sentAt.toIso8601String(),
      });

  @override
  String debugExtraInfo() => '';

  @override
  bool get hideInDebugPanel => true;

  @override
  String get debugName => 'Ping';
}
