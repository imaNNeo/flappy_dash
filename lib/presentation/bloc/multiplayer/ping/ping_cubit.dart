import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'ping_state.dart';

class PingCubit extends Cubit<PingState> {
  PingCubit(
    this._multiplayerRepository,
  ) : super(const PingState()) {
    _initializePing();
  }

  final MultiplayerRepository _multiplayerRepository;
  ({StreamSubscription subscription, String matchId})? _streamSubscription;

  late final Timer _pingTimer;

  static const _pingTimeout = Duration(seconds: 5);

  void _initializePing() {
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tryToSendPing();
    });
  }

  void _tryToSendPing() {
    final currentMatch = _multiplayerRepository.currentMatch.value;
    if (currentMatch == null) {
      return;
    }

    final matchId = currentMatch.matchId;
    if (_streamSubscription == null ||
        _streamSubscription!.matchId != matchId) {
      _streamSubscription?.subscription.cancel();
      _multiplayerRepository.matchUpdatesBufferedQueue;
      _streamSubscription = (
        subscription: _multiplayerRepository.generalMatchEvents
            .where((event) => event.matchId == matchId)
            .listen(_onMatchEvent),
        matchId: matchId,
      );
    }

    final lastPingSentAt = state.lastPingSentAt;
    if (lastPingSentAt == null) {
      _newPing();
      return;
    }

    final sinceLastPing = DateTime.now().difference(lastPingSentAt.time);
    if (sinceLastPing > _pingTimeout) {
      emit(state.copyWith(
        lastPingSentAt: const ValueWrapper(null),
        currentPing: const ValueWrapper(null),
      ));
      _newPing();
    }
  }

  void _newPing() {
    final matchId = _multiplayerRepository.currentMatch.value!.matchId;
    final pingId = const Uuid().v4();
    final pingSentAt = DateTime.now();
    _multiplayerRepository.sendDispatchingEvent(
      matchId,
      DispatchingPingEvent(
        state.currentPing?.total ?? 0,
        pingId,
        pingSentAt,
      ),
    );
    emit(state.copyWith(
      lastPingSentAt: ValueWrapper((
        pingId: pingId,
        time: pingSentAt,
      )),
    ));
  }

  void _onMatchEvent(MatchEvent event) {
    if (event is MatchPongEvent) {
      final currentWaitingPing = state.lastPingSentAt;
      if (event.pingId == currentWaitingPing?.pingId) {
        final pingSentAt = currentWaitingPing!.time;
        final serverReceiveTime = event.serverReceiveTime;
        final now = DateTime.now();

        final sendPing =
            serverReceiveTime.difference(pingSentAt).inMilliseconds.abs();
        final receivePing =
            now.difference(serverReceiveTime).inMilliseconds.abs();
        final totalPing = now.difference(pingSentAt).inMilliseconds.abs();
        emit(state.copyWith(
          currentPing: ValueWrapper((
            total: totalPing,
            send: sendPing,
            recieve: receivePing,
          )),
          lastPingSentAt: const ValueWrapper(null),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _pingTimer.cancel();
    _streamSubscription?.subscription.cancel();
    return super.close();
  }
}
