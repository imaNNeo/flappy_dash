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

class DispatchingUserDisplayNameUpdatedEvent extends DispatchingMatchEvent {
  DispatchingUserDisplayNameUpdatedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'UserDisplayNameUpdated';
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
  DispatchingPlayerJumpedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerJumped';
}

class DispatchingPlayerScoredEvent extends DispatchingMatchEvent {
  DispatchingPlayerScoredEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerScored';
}

class DispatchingPlayerDiedEvent extends DispatchingMatchEvent {
  DispatchingPlayerDiedEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerDied';
}

class DispatchingPlayerFullStateNeededEvent extends DispatchingMatchEvent {
  DispatchingPlayerFullStateNeededEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'PlayerFullStateNeeded';
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
