import 'dart:convert';

import 'package:flappy_dash/domain/extensions/string_extension.dart';
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
}

// Match events:
class MatchWelcomeEvent extends MatchEvent with HasMatchState {
  MatchWelcomeEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class MatchWaitingTimeIncreasedEvent extends MatchEvent with HasMatchState {
  MatchWaitingTimeIncreasedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class MatchPresencesUpdatedEvent extends MatchEvent with HasMatchState {
  MatchPresencesUpdatedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class MatchStartedEvent extends MatchEvent with HasMatchState {
  MatchStartedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class MatchFinishedEvent extends MatchEvent with HasMatchState {
  MatchFinishedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
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
}

// Player Events:
class PlayerJoinedTheLobby extends MatchEvent with HasMatchState {
  PlayerJoinedTheLobby(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class PlayerStartedEvent extends MatchEvent with HasMatchState {
  PlayerStartedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerJumpedEvent extends MatchEvent with HasMatchState {
  PlayerJumpedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerScoredEvent extends MatchEvent with HasMatchState {
  PlayerScoredEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerDiedEvent extends MatchEvent with HasMatchState {
  PlayerDiedEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerIsIdleEvent extends MatchEvent with HasMatchState {
  PlayerIsIdleEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerKickedFromTheLobbyEvent extends MatchEvent with HasMatchState {
  PlayerKickedFromTheLobbyEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }
}

class PlayerCorrectPositionEvent extends MatchEvent with HasMatchState {
  PlayerCorrectPositionEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;

  double get dashVelocityY => state.players[sender!.userId]!.lastKnownVelocityY;
}

class PlayerWillSpawnAtEvent extends MatchEvent with HasMatchState {
  PlayerWillSpawnAtEvent(MatchData matchData) : super(matchData) {
    data = matchData;
  }

  double get dashX => state.players[sender!.userId]!.lastKnownX;

  double get dashY => state.players[sender!.userId]!.lastKnownY;
}
