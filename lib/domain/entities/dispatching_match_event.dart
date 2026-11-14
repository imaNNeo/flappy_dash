import 'dart:convert';

import 'package:flappy_dash/domain/netcode/net_protocol.dart';

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

class DispatchingPingEvent extends DispatchingMatchEvent {
  final int previousPing;
  final String pingId;
  final DateTime sentAt;

  DispatchingPingEvent(this.previousPing, this.pingId, this.sentAt);

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

/// The player's input commands (see [InputPacket]), many times a second.
class DispatchingPlayerInputEvent extends DispatchingMatchEvent {
  final InputPacket packet;

  DispatchingPlayerInputEvent(this.packet);

  @override
  List<int> toBytes() => packet.toBytes();

  @override
  String debugExtraInfo() => packet.toString();

  @override
  bool get hideInDebugPanel => true;

  @override
  String get debugName => 'PlayerInput';
}

/// Asks the server to add a bot to the waiting match. The server ignores it
/// unless this user may manage bots (see [NakamaDataSource.canManageBots]).
class DispatchingBotAddEvent extends DispatchingMatchEvent {
  DispatchingBotAddEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'BotAdd';
}

/// Asks the server to remove the last added bot from the waiting match.
class DispatchingBotRemoveEvent extends DispatchingMatchEvent {
  DispatchingBotRemoveEvent();

  @override
  List<int> toBytes() => [];

  @override
  String debugExtraInfo() => '';

  @override
  String get debugName => 'BotRemove';
}
