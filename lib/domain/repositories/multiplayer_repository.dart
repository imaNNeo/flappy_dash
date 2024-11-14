import 'dart:async';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/match_overview_entity.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:nakama/nakama.dart';

class MultiplayerRepository {
  final NakamaDataSource _nakamaDataSource;

  MultiplayerRepository(this._nakamaDataSource);

  ValueNotifier<Match?> currentMatch = ValueNotifier(null);

  Future<String> getWaitingMatchId() => _nakamaDataSource.getWaitingMatchId();

  Stream<MatchEvent> onMatchEvent(String matchId) =>
      _nakamaDataSource.onMatchEvent(matchId);

  final _onEventDispatchedController =
      StreamController<DispatchingMatchEvent>.broadcast();

  Stream<DispatchingMatchEvent> onEventDispatched() =>
      _onEventDispatchedController.stream;

  Future<Match> joinMatch(String matchId) async {
    final match = await _nakamaDataSource.joinMatch(matchId);
    currentMatch.value = match;
    return match;
  }

  void joinLobby(String matchId) => sendDispatchingEvent(
        matchId,
        DispatchingPlayerJoinedLobbyEvent(),
      );

  Future<void> leaveMatch(String matchId) async {
    await _nakamaDataSource.leaveMatch(matchId);
    currentMatch.value = null;
  }

  void sendUserDisplayNameUpdatedEvent(String matchId) => sendDispatchingEvent(
        matchId,
        DispatchingUserDisplayNameUpdatedEvent(),
      );

  void sendDispatchingEvent(String matchId, DispatchingMatchEvent event) {
    _onEventDispatchedController.add(event);
    _nakamaDataSource.sendDispatchingEvent(
      matchId,
      event,
    );
  }

  Future<MatchResultEntity> getMatchResult(String matchId) =>
      _nakamaDataSource.getMatchResult(matchId);

  Future<MatchOverviewEntity> getLastMatchOverview() =>
      _nakamaDataSource.getLastMatchOverview();
}
