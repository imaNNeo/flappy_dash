import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:nakama/nakama.dart';

enum MatchEventOpCode {
  // Match events
  matchWelcome(100),
  matchWaitingTimeIncreased(101),
  matchPlayersJoined(102),
  matchPlayersLeft(103),
  matchPlayerNameUpdated(104),
  matchStarted(105),
  matchFinished(106),
  matchPing(107),
  matchPong(108),

  // Player events
  playerJoinedTheLobby(200),
  playerTickUpdate(201),
  playerStarted(202),
  playerJumped(203),
  playerScored(204),
  playerDied(205),
  playerKickedFromTheLobby(206),
  playerFullStateNeeded(207);

  final int opCode;

  const MatchEventOpCode(this.opCode);

  MatchEvent parseIncomingEvent(MatchData data) => switch (this) {
        MatchEventOpCode.matchWelcome => MatchWelcomeEvent(data),
        MatchEventOpCode.matchWaitingTimeIncreased =>
          MatchWaitingTimeIncreasedEvent(data),
        MatchEventOpCode.matchPlayersJoined => MatchPlayersJoined(data),
        MatchEventOpCode.matchPlayersLeft => MatchPlayersLeft(data),
        MatchEventOpCode.matchPlayerNameUpdated =>
          MatchPlayerNameUpdatedEvent(data),
        MatchEventOpCode.matchStarted => MatchStartedEvent(data),
        MatchEventOpCode.matchFinished => MatchFinishedEvent(data),
        MatchEventOpCode.matchPong => MatchPongEvent(data),
        MatchEventOpCode.playerJoinedTheLobby => PlayerJoinedTheLobby(data),
        MatchEventOpCode.playerKickedFromTheLobby =>
          PlayerKickedFromTheLobbyEvent(data),
        MatchEventOpCode.playerTickUpdate => PlayerTickUpdateEvent(data),
        MatchEventOpCode.playerFullStateNeeded =>
          PlayerFullStateNeededEvent(data),
        MatchEventOpCode.playerStarted ||
        MatchEventOpCode.playerJumped ||
        MatchEventOpCode.playerScored ||
        MatchEventOpCode.playerDied ||
        MatchEventOpCode.matchPing =>
          throw StateError('$this is not a valid incoming event'),
      };

  static MatchEventOpCode fromDispatchingEvent(DispatchingMatchEvent event) =>
      switch (event) {
        DispatchingPlayerJoinedLobbyEvent() =>
          MatchEventOpCode.playerJoinedTheLobby,
        DispatchingPlayerStartedEvent() => MatchEventOpCode.playerStarted,
        DispatchingPlayerJumpedEvent() => MatchEventOpCode.playerJumped,
        DispatchingPlayerScoredEvent() => MatchEventOpCode.playerScored,
        DispatchingPlayerDiedEvent() => MatchEventOpCode.playerDied,
        DispatchingUserDisplayNameUpdatedEvent() =>
          MatchEventOpCode.matchPlayerNameUpdated,
        DispatchingPingEvent() => MatchEventOpCode.matchPing,
        DispatchingPlayerFullStateNeededEvent() =>
          MatchEventOpCode.playerFullStateNeeded,
      };
}
