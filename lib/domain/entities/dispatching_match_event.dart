import 'dart:convert';

List<int> _jsonToData(Map<String, dynamic> json) =>
    utf8.encode(jsonEncode(json));

sealed class DispatchingMatchEvent {
  const DispatchingMatchEvent();

  List<int> toBytes();

  String debugExtraInfo();
}

class DispatchingPlayerJoinedLobbyEvent extends DispatchingMatchEvent {
  DispatchingPlayerJoinedLobbyEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';
}

class DispatchingPlayerStartedEvent extends DispatchingMatchEvent {
  DispatchingPlayerStartedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';
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
  String debugExtraInfo() => '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';
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
  String debugExtraInfo() => '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';
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
  String debugExtraInfo() => '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';
}

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';
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
  String debugExtraInfo() => '(${positionX.toStringAsFixed(1)}, ${positionY.toStringAsFixed(1)})';
}
