import 'dart:convert';

import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/domain/netcode/net_protocol.dart';
import 'package:nakama/nakama.dart';

import 'match_state.dart';

mixin HasMatchState {
  late final MatchData data;

  late MatchState state = MatchState.fromJson(
    jsonDecode(utf8.decode(data.data!)),
  );
}

sealed class MatchEvent {
  MatchEvent(MatchData matchData) {
    sender =
        matchData.presence == null || matchData.presence!.userId.isNullOrBlank
        ? null
        : matchData.presence!;
  }

  late UserPresence? sender;

  bool get hideInDebugPanel => false;

  String get debugName;
}

// Match events:
class MatchWelcomeEvent extends MatchEvent with HasMatchState {
  MatchWelcomeEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'MatchWelcome';
}

class MatchWaitingTimeIncreasedEvent extends MatchEvent with HasMatchState {
  MatchWaitingTimeIncreasedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'MatchWaitingTimeIncreased';
}

class MatchPresencesUpdatedEvent extends MatchEvent with HasMatchState {
  MatchPresencesUpdatedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'MatchPresencesUpdated';
}

class MatchStartedEvent extends MatchEvent with HasMatchState {
  MatchStartedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'MatchStarted';
}

class MatchFinishedEvent extends MatchEvent with HasMatchState {
  MatchFinishedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'MatchFinished';
}

class MatchPongEvent extends MatchEvent {
  MatchPongEvent(MatchData matchData) : super(matchData) {
    final json = jsonDecode(utf8.decode(matchData.data!));
    serverReceiveTime = DateTime.fromMillisecondsSinceEpoch(
      json['serverReceiveTime'],
    );
    pingId = json['pingId'];
  }

  late final DateTime serverReceiveTime;
  late final String pingId;

  @override
  bool get hideInDebugPanel => true;

  @override
  String get debugName => 'MatchPong';
}

/// Binary, 20 times a second while the match runs (see [Snapshot]).
class MatchSnapshotEvent extends MatchEvent {
  MatchSnapshotEvent(super.matchData)
    : snapshot = Snapshot.fromBytes(matchData.data!);

  final Snapshot snapshot;

  @override
  bool get hideInDebugPanel => true;

  @override
  String get debugName => 'MatchSnapshot';
}

// Player Events:
class PlayerJoinedTheLobby extends MatchEvent with HasMatchState {
  PlayerJoinedTheLobby(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerJoinedTheLobby';
}

class PlayerStartedEvent extends MatchEvent with HasMatchState {
  PlayerStartedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerStarted';
}

class PlayerScoredEvent extends MatchEvent with HasMatchState {
  PlayerScoredEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerScored';
}

class PlayerDiedEvent extends MatchEvent with HasMatchState {
  PlayerDiedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerDied';
}

class PlayerIsIdleEvent extends MatchEvent with HasMatchState {
  PlayerIsIdleEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerIsIdle';
}

class PlayerKickedFromTheLobbyEvent extends MatchEvent with HasMatchState {
  PlayerKickedFromTheLobbyEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerKickedFromTheLobby';
}

class PlayerWillSpawnAtEvent extends MatchEvent with HasMatchState {
  PlayerWillSpawnAtEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  @override
  String get debugName => 'PlayerWillSpawnAt';
}
