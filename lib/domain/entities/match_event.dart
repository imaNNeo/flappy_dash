import 'dart:convert';

import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:nakama/nakama.dart';

import 'match_state.dart';

sealed class MatchEvent {
  MatchEvent(MatchData matchData)
      : state = MatchState.fromJson(jsonDecode(utf8.decode(matchData.data!))),
        sender = matchData.presence == null ||
                matchData.presence!.userId.isNullOrBlank
            ? null
            : matchData.presence!;

  final MatchState state;
  final UserPresence? sender;
}

// Match events:
class MatchWelcomeEvent extends MatchEvent {
  MatchWelcomeEvent(super.matchData);
}

class MatchWaitingTimeIncreasedEvent extends MatchEvent {
  MatchWaitingTimeIncreasedEvent(super.matchData);
}

class MatchPresencesUpdatedEvent extends MatchEvent {
  MatchPresencesUpdatedEvent(super.matchData);
}

class MatchStartedEvent extends MatchEvent {
  MatchStartedEvent(super.matchData);
}

class MatchFinishedEvent extends MatchEvent {
  MatchFinishedEvent(super.matchData);
}

// Player Events:
class PlayerJoinedTheLobby extends MatchEvent {
  PlayerJoinedTheLobby(super.matchData);
}

class PlayerStartedEvent extends MatchEvent {
  PlayerStartedEvent(super.matchData);
}

class PlayerJumpedEvent extends MatchEvent {
  PlayerJumpedEvent(super.matchData);
}

class PlayerScoredEvent extends MatchEvent {
  PlayerScoredEvent(super.matchData);
}

class PlayerDiedEvent extends MatchEvent {
  PlayerDiedEvent(super.matchData);
}

class PlayerIsIdleEvent extends MatchEvent {
  PlayerIsIdleEvent(super.matchData);
}

class PlayerStartedAgainEvent extends MatchEvent {
  PlayerStartedAgainEvent(super.matchData);
}

class PlayerKickedFromTheLobbyEvent extends MatchEvent {
  PlayerKickedFromTheLobbyEvent(super.matchData);
}

class PlayerCorrectPositionEvent extends MatchEvent {
  PlayerCorrectPositionEvent(super.matchData);
}
