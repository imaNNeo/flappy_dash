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

  final matchUpdatesBufferedQueue = <PlayerTickUpdateEvent>[];

  final _generalEventsController =
      StreamController<MatchGeneralEvent>.broadcast();
  final _updateTickEventController =
      StreamController<PlayerTickUpdateEvent>.broadcast();

  final Map<String, StreamSubscription> _matchIdAndSubscription = {};

  Stream<MatchGeneralEvent> get generalMatchEvents =>
      _generalEventsController.stream;

  Stream<PlayerTickUpdateEvent> get updateTickEventsStream =>
      _updateTickEventController.stream;

  void startListeningToMatchEvents(String matchId) {
    const matchTickRate = 40;
    const bufferTime = Duration(milliseconds: 100);
    const timeBetweenTicks = Duration(milliseconds: 1000 ~/ matchTickRate);
    const missingTicksToFullRefreshThreshold = 5;

    Timer.periodic(timeBetweenTicks, (_) {
      for (int i = 0; i < matchUpdatesBufferedQueue.length; i++) {
        final waitingEvent = matchUpdatesBufferedQueue[i];
        final eventAt = waitingEvent.diff.tickTimestamp;
        final timePassed = DateTime.now().millisecondsSinceEpoch - eventAt;
        if (timePassed < bufferTime.inMilliseconds) {
          // We can't send the this event and the others (as they're sorted)
          break;
        }
        _updateTickEventController.add(matchUpdatesBufferedQueue.removeAt(i));
      }
    });
    final baseSubscription =
        _nakamaDataSource.onMatchEvent(matchId).listen((event) {
      if (!event.hideInDebugPanel) {
        print('Received event: $event');
      }
      switch (event) {
        case PlayerTickUpdateEvent():
          final newTickNumber = event.diff.tickNumber;

          final lastTickNumber = matchUpdatesBufferedQueue.isNotEmpty
              ? matchUpdatesBufferedQueue.last.diff.tickNumber
              : -1;

          // Check if there are too many missing ticks
          if (lastTickNumber != -1 &&
              newTickNumber - lastTickNumber >
                  missingTicksToFullRefreshThreshold) {
            // Todo: request for full refresh
          }

          // Reorder the queue if there's a missing tick
          if (newTickNumber < lastTickNumber) {
            for (var i = 0; i < matchUpdatesBufferedQueue.length; i++) {
              if (matchUpdatesBufferedQueue[i].diff.tickNumber >
                  newTickNumber) {
                matchUpdatesBufferedQueue.insert(i, event);
                break;
              }
            }
          }

          matchUpdatesBufferedQueue.add(event);
          break;
        case MatchWelcomeEvent():
        case MatchWaitingTimeIncreasedEvent():
        case MatchPlayersJoined():
        case MatchPlayersLeft():
        case MatchPlayerNameUpdatedEvent():
        case MatchStartedEvent():
        case MatchFinishedEvent():
        case MatchPongEvent():
        case PlayerJoinedTheLobby():
        case PlayerKickedFromTheLobbyEvent():
        case PlayerFullStateNeededEvent():
          if (event is MatchStartedEvent) {
            _startListeningToUpdateTicks(matchId);
          }
          _generalEventsController.add(event as MatchGeneralEvent);
          break;
      }
    });
    baseSubscription.onDone(() {
      _updateTickEventController.close();
      _generalEventsController.close();
    });
    _matchIdAndSubscription[matchId] = baseSubscription;
  }

  void _startListeningToUpdateTicks(String matchId) {
    matchUpdatesBufferedQueue.clear();
  }

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
    _matchIdAndSubscription[matchId]?.cancel();
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
