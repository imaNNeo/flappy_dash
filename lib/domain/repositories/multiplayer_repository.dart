import 'dart:async';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:nakama/nakama.dart';

class MultiplayerRepository {
  final NakamaDataSource _nakamaDataSource;

  MultiplayerRepository(this._nakamaDataSource);

  Future<String> getWaitingMatchId() => _nakamaDataSource.getWaitingMatchId();

  Stream<MatchEvent> onMatchEvent(String matchId) =>
      _nakamaDataSource.onMatchEvent(matchId);

  Future<Match> joinMatch(String matchId) =>
      _nakamaDataSource.joinMatch(matchId);

  void joinLobby(String matchId) {
    _nakamaDataSource.sendDispatchingEvent(
      matchId,
      DispatchingPlayerJoinedLobbyEvent(),
    );
  }

  Future<void> leaveMatch(String matchId) =>
      _nakamaDataSource.leaveMatch(matchId);

  void sendUserDisplayNameUpdatedEvent(String matchId) {
    _nakamaDataSource.sendDispatchingEvent(
      matchId,
      DispatchingUserDisplayNameUpdatedEvent(),
    );
  }
}
