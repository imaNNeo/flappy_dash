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
  matchPing(105),
  matchPong(106),
  matchSnapshot(110),
  // Player events
  playerJoinedTheLobby(200),
  playerStarted(201),
  // 202 (playerJumped) and 207 (playerCorrectPosition) were the old
  // client-authoritative position updates; the server simulates now.
  playerScored(203),
  playerDied(204),
  playerIsIdle(205),
  playerKickedFromTheLobby(206),
  playerDisplayNameUpdated(208),
  playerWillSpawnsAt(209),
  playerInput(210),
  botAdd(211),
  botRemove(212);

  final int opCode;

  const MatchEventOpCode(this.opCode);

  static final Map<int, MatchEventOpCode> _byOpCode = {
    for (final value in values) value.opCode: value,
  };

  static MatchEventOpCode? fromOpCode(int opCode) => _byOpCode[opCode];

  MatchEvent parseIncomingEvent(MatchData data) => switch (this) {
    MatchEventOpCode.matchWelcome => MatchWelcomeEvent(data),
    MatchEventOpCode.matchWaitingTimeIncreased =>
      MatchWaitingTimeIncreasedEvent(data),
    MatchEventOpCode.matchPresencesUpdated => MatchPresencesUpdatedEvent(data),
    MatchEventOpCode.matchStarted => MatchStartedEvent(data),
    MatchEventOpCode.matchFinished => MatchFinishedEvent(data),
    MatchEventOpCode.matchPong => MatchPongEvent(data),
    MatchEventOpCode.matchSnapshot => MatchSnapshotEvent(data),
    MatchEventOpCode.playerJoinedTheLobby => PlayerJoinedTheLobby(data),
    MatchEventOpCode.playerStarted => PlayerStartedEvent(data),
    MatchEventOpCode.playerScored => PlayerScoredEvent(data),
    MatchEventOpCode.playerDied => PlayerDiedEvent(data),
    MatchEventOpCode.playerIsIdle => PlayerIsIdleEvent(data),
    MatchEventOpCode.playerKickedFromTheLobby => PlayerKickedFromTheLobbyEvent(
      data,
    ),
    MatchEventOpCode.playerWillSpawnsAt => PlayerWillSpawnAtEvent(data),
    MatchEventOpCode.matchPing ||
    MatchEventOpCode.playerDisplayNameUpdated ||
    MatchEventOpCode.playerInput ||
    MatchEventOpCode.botAdd ||
    MatchEventOpCode.botRemove => throw UnimplementedError(
      'It is not an incoming event',
    ),
  };

  static MatchEventOpCode fromDispatchingEvent(DispatchingMatchEvent event) =>
      switch (event) {
        DispatchingPlayerJoinedLobbyEvent() =>
          MatchEventOpCode.playerJoinedTheLobby,
        DispatchingUserDisplayNameUpdatedEvent() =>
          MatchEventOpCode.playerDisplayNameUpdated,
        DispatchingPlayerInputEvent() => MatchEventOpCode.playerInput,
        DispatchingPingEvent() => MatchEventOpCode.matchPing,
        DispatchingBotAddEvent() => MatchEventOpCode.botAdd,
        DispatchingBotRemoveEvent() => MatchEventOpCode.botRemove,
      };
}
