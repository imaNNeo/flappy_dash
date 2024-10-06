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

  DispatchingPlayerJumpedEvent(this.positionX);

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
      });
}

class DispatchingPlayerScoredEvent extends DispatchingMatchEvent {
  final double positionX;

  DispatchingPlayerScoredEvent(this.positionX);

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
      });
}

class DispatchingPlayerDiedEvent extends DispatchingMatchEvent {
  final double positionX;

  DispatchingPlayerDiedEvent(this.positionX);

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
      });
}

class DispatchingPlayerIsIdleEvent extends DispatchingMatchEvent {
  DispatchingPlayerIsIdleEvent();

  @override
  List<int> toBytes() => [];
}

class DispatchingPlayerKickedFromLobbyEvent extends DispatchingMatchEvent {
  final double positionX;

  DispatchingPlayerKickedFromLobbyEvent(this.positionX);

  @override
  List<int> toBytes() => _jsonToData({
        'positionX': positionX,
      });
}

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];
}