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

  DispatchingPlayerJumpedEvent(
    this.positionX,
    this.positionY,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
      });
}

class DispatchingPlayerScoredEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;

  DispatchingPlayerScoredEvent(
    this.positionX,
    this.positionY,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
      });
}

class DispatchingPlayerDiedEvent extends DispatchingMatchEvent {
  final double positionX;
  final double positionY;

  DispatchingPlayerDiedEvent(
    this.positionX,
    this.positionY,
  );

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
        'positionY': positionY,
      });
}

class DispatchingPlayerIsIdleEvent extends DispatchingMatchEvent {
  DispatchingPlayerIsIdleEvent();

  @override
  List<int> toBytes() => [];
}

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];
}
