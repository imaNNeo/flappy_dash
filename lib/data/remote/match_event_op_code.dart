import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:nakama/nakama.dart';

enum MatchEventOpCode {
  // Match events
  matchWelcome(100),
  matchWaitingTimeIncreased(101),
  matchPresencesUpdated(102),
  matchStarted(103),
  matchFinished(104),
  // Player events
  playerJoinedTheLobby(200),
  playerStarted(201),
  playerJumped(202),
  playerScored(203),
  playerDied(204),
  playerIsIdle(205),
  playerKickedFromTheLobby(206),
  playerCorrectPosition(207),
  playerDisplayNameUpdated(208),
  playerWillSpawnsAt(209);

  final int opCode;

  const MatchEventOpCode(this.opCode);

  MatchEvent parseIncomingEvent(MatchData data) => switch (this) {
        MatchEventOpCode.matchWelcome => MatchWelcomeEvent(data),
        MatchEventOpCode.matchWaitingTimeIncreased =>
          MatchWaitingTimeIncreasedEvent(data),
        MatchEventOpCode.matchPresencesUpdated =>
          MatchPresencesUpdatedEvent(data),
        MatchEventOpCode.matchStarted => MatchStartedEvent(data),
        MatchEventOpCode.matchFinished => MatchFinishedEvent(data),
        MatchEventOpCode.playerJoinedTheLobby => PlayerJoinedTheLobby(data),
        MatchEventOpCode.playerStarted => PlayerStartedEvent(data),
        MatchEventOpCode.playerJumped => PlayerJumpedEvent(data),
        MatchEventOpCode.playerScored => PlayerScoredEvent(data),
        MatchEventOpCode.playerDied => PlayerDiedEvent(data),
        MatchEventOpCode.playerIsIdle => PlayerIsIdleEvent(data),
        MatchEventOpCode.playerKickedFromTheLobby =>
          PlayerKickedFromTheLobbyEvent(data),
        MatchEventOpCode.playerCorrectPosition =>
          PlayerCorrectPositionEvent(data),
        MatchEventOpCode.playerDisplayNameUpdated =>
          throw UnimplementedError('It is not an incoming event'),
        MatchEventOpCode.playerWillSpawnsAt => PlayerWillSpawnAtEvent(data),
      };

  static MatchEventOpCode fromDispatchingEvent(DispatchingMatchEvent event) =>
      switch (event) {
        DispatchingPlayerJoinedLobbyEvent() =>
          MatchEventOpCode.playerJoinedTheLobby,
        DispatchingPlayerStartedEvent() => MatchEventOpCode.playerStarted,
        DispatchingPlayerJumpedEvent() => MatchEventOpCode.playerJumped,
        DispatchingPlayerScoredEvent() => MatchEventOpCode.playerScored,
        DispatchingPlayerDiedEvent() => MatchEventOpCode.playerDied,
        DispatchingPlayerIsIdleEvent() => MatchEventOpCode.playerIsIdle,
        DispatchingUserDisplayNameUpdatedEvent() =>
          MatchEventOpCode.playerDisplayNameUpdated,
        DispatchingPlayerCorrectPositionEvent() =>
          MatchEventOpCode.playerCorrectPosition,
      };
}
