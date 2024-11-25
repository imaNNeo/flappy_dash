import 'dart:convert';

import 'package:flappy_dash/domain/entities/match_diff_entity.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:nakama/nakama.dart';

import 'match_state.dart';

mixin HasMatchState {}

sealed class MatchEvent {
  MatchEvent(MatchData matchData) {
    sender =
        matchData.presence == null || matchData.presence!.userId.isNullOrBlank
            ? null
            : matchData.presence!;
    matchId = matchData.matchId;
  }

  late String matchId;

  late UserPresence? sender;

  bool get hideInDebugPanel => false;

  String get debugName;
}

// Match events:
class MatchWelcomeEvent extends MatchEvent with HasMatchState {
  MatchWelcomeEvent(super.matchData)
      : matchState = MatchState.fromJson(
          jsonDecode(utf8.decode(matchData.data!)),
        );

  final MatchState matchState;

  @override
  String get debugName => 'MatchWelcome';
}

class MatchWaitingTimeIncreasedEvent extends MatchEvent with HasMatchState {
  MatchWaitingTimeIncreasedEvent(super.matchData)
      : newMatchRunsAt = DateTime.fromMillisecondsSinceEpoch(
          jsonDecode(utf8.decode(matchData.data!))['newMatchRunsAt'],
        );

  final DateTime newMatchRunsAt;

  @override
  String get debugName => 'MatchWaitingTimeIncreased';
}

class MatchPlayersJoined extends MatchEvent with HasMatchState {
  MatchPlayersJoined(super.matchData)
      : joinedPlayersInfo = (jsonDecode(utf8.decode(matchData.data!)) as Map)
            .map(
              (key, value) => MapEntry(
                key,
                PlayerState.fromJson(value),
              ),
            );

  final Map<String, PlayerState> joinedPlayersInfo;

  @override
  String get debugName => 'MatchPlayersJoined';
}

class MatchPlayersLeft extends MatchEvent with HasMatchState {
  MatchPlayersLeft(super.matchData)
      : leftPlayerIds =
            (jsonDecode(utf8.decode(matchData.data!)) as List).cast<String>();

  final List<String> leftPlayerIds;

  @override
  String get debugName => 'MatchPlayersLeft';
}

class MatchPlayerNameUpdatedEvent extends MatchEvent with HasMatchState {
  MatchPlayerNameUpdatedEvent(super.matchData)
      : newDisplayName =
            jsonDecode(utf8.decode(matchData.data!))['newDisplayName'];

  final String newDisplayName;

  @override
  String get debugName => 'MatchPlayerNameUpdated';
}

class MatchStartedEvent extends MatchEvent with HasMatchState {
  MatchStartedEvent(super.matchData)
      : matchState = MatchState.fromJson(
          jsonDecode(utf8.decode(matchData.data!)),
        );

  final MatchState matchState;

  @override
  String get debugName => 'MatchStarted';
}

class MatchFinishedEvent extends MatchEvent with HasMatchState {
  MatchFinishedEvent(super.matchData);

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

// Player Events:
class PlayerJoinedTheLobby extends MatchEvent with HasMatchState {
  PlayerJoinedTheLobby(super.matchData)
      : joinedPlayer = PlayerState.fromJson(
          jsonDecode(utf8.decode(matchData.data!)),
        );

  final PlayerState joinedPlayer;

  @override
  String get debugName => 'PlayerJoinedTheLobby';
}

class PlayerTickUpdateEvent extends MatchEvent with HasMatchState {
  PlayerTickUpdateEvent(super.matchData)
      : diff = MatchDiffEntity.fromJson(
          jsonDecode(utf8.decode(matchData.data!)),
        );

  final MatchDiffEntity diff;

  @override
  String get debugName => 'PlayerTickUpdate';
}

class PlayerKickedFromTheLobbyEvent extends MatchEvent with HasMatchState {
  PlayerKickedFromTheLobbyEvent(super.matchData);

  @override
  String get debugName => 'PlayerKickedFromTheLobby';
}

class PlayerFullStateNeededEvent extends MatchEvent with HasMatchState {
  PlayerFullStateNeededEvent(super.matchData)
      : matchState = MatchState.fromJson(
          jsonDecode(utf8.decode(matchData.data!)),
        );
  final MatchState matchState;

  @override
  String get debugName => 'PlayerFullStateNeeded';
}
