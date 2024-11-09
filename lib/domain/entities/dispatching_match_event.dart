import 'dart:convert';

List<int> _jsonToData(Map<String, dynamic> json) =>
    utf8.encode(jsonEncode(json));

sealed class DispatchingMatchEvent {
  const DispatchingMatchEvent();

  List<int> toBytes();
}

class DispatchingPlayerJoinedLobbyEvent extends DispatchingMatchEvent {
  DispatchingPlayerJoinedLobbyEvent();

  @override
  List<int> toBytes() => [];
}

class DispatchingPlayerStartedEvent extends DispatchingMatchEvent {
  DispatchingPlayerStartedEvent();

  @override
  List<int> toBytes() => [];
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
}

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];
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
}
