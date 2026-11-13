// Replays the traffic of a busy 2-minute multiplayer match (20 players) through
// the real MultiplayerCubit and reports how long the client spends on it.
//
//   flutter test test/perf/multiplayer_traffic_benchmark_test.dart
//
// This is a benchmark, not a correctness test: it prints numbers and only fails
// if the cubit stops reacting to the events.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/data/remote/match_event_op_code.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nakama/nakama.dart';

const _players = 20;
const _matchSeconds = 120;
// What the load bot measured per player: ~60 messages per second at 20 players.
const _eventsPerSecond = 60;
const _matchId = 'bench-match';

String _id(int i) =>
    '${i.toString().padLeft(8, '0')}-0000-4000-8000-000000000000';

final _random = Random(1);

Map<String, dynamic> _state(int phase, int scoreBoost) => {
  'matchInitializedAt': 1700000000000,
  'matchRunsAt': DateTime.now().millisecondsSinceEpoch,
  'matchFinishesAt': DateTime.now().millisecondsSinceEpoch + 120000,
  'currentPhase': phase,
  'presences': [
    for (var i = 0; i < _players; i++)
      {'userId': _id(i), 'sessionId': _id(i + 100), 'username': 'player$i'},
  ],
  'players': {
    for (var i = 0; i < _players; i++)
      _id(i): {
        'userId': _id(i),
        'displayName': 'Player $i',
        'isInLobby': true,
        'lastKnownX': _random.nextDouble() * 4000,
        'lastKnownY': _random.nextDouble() * 400 - 200,
        'lastKnownVelocityY': -500.0,
        'score': scoreBoost + i,
        'playingState': 1,
        'spawnsAgainAt': 0,
      },
  },
  'pipesPositions': [for (var i = 0; i < _players; i++) _random.nextDouble()],
};

MatchData _data(MatchEventOpCode op, int sender, Map<String, dynamic> state) =>
    MatchData(
      matchId: _matchId,
      opCode: op.opCode,
      presence: UserPresence(
        userId: _id(sender),
        sessionId: _id(sender + 100),
        username: 'player$sender',
        persistence: false,
      ),
      data: utf8.encode(jsonEncode(state)),
      reliable: true,
    );

class _FakeGameRepository extends Fake implements GameRepository {
  @override
  Future<String> getCurrentUserId() async => _id(0);

  @override
  Stream<Account> getUserAccountUpdateStream() => const Stream.empty();
}

class _FakeAudioHelper extends Fake implements AudioHelper {
  @override
  void playBackgroundAudio() {}

  @override
  void stopBackgroundAudio({bool immediately = false}) {}

  @override
  void playScoreCollectSound() {}
}

class _FakeMultiplayerRepository extends Fake implements MultiplayerRepository {
  final events = StreamController<MatchEvent>.broadcast(sync: true);

  @override
  ValueNotifier<Match?> currentMatch = ValueNotifier(null);

  @override
  Stream<void> get onReconnected => const Stream.empty();

  @override
  Stream<DispatchingMatchEvent> onEventDispatched() => const Stream.empty();

  @override
  Stream<MatchEvent> onMatchEvent(String matchId) => events.stream;

  @override
  Future<Match> joinMatch(String matchId) async => Match(
    matchId: matchId,
    authoritative: true,
    label: '',
    size: _players,
    presences: const [],
  );

  @override
  void sendDispatchingEvent(String matchId, DispatchingMatchEvent event) {}

  @override
  Future<void> leaveMatch(String matchId) async {}
}

void main() {
  test('20-player match traffic through MultiplayerCubit', () async {
    final repo = _FakeMultiplayerRepository();
    final cubit = MultiplayerCubit(
      repo,
      _FakeGameRepository(),
      _FakeAudioHelper(),
    );
    await Future<void>.delayed(Duration.zero);
    cubit.joinMatch(_matchId);
    await Future<void>.delayed(Duration.zero);

    var emits = 0;
    // How often the game page's main builder and its scoreboard would rebuild
    // with the conditions they use now (before, every emit rebuilt both).
    var pageBuilds = 0;
    var scoreboardBuilds = 0;
    var previous = cubit.state;
    final sub = cubit.stream.listen((current) {
      emits++;
      if (previous.currentPlayingState != current.currentPlayingState ||
          previous.currentScore != current.currentScore) {
        pageBuilds++;
      }
      final a = previous.matchState?.players;
      final b = current.matchState?.players;
      if (!identical(a, b) &&
          (a == null ||
              b == null ||
              a.length != b.length ||
              b.entries.any(
                (e) =>
                    a[e.key]?.score != e.value.score ||
                    a[e.key]?.displayName != e.value.displayName,
              ))) {
        scoreboardBuilds++;
      }
      previous = current;
    });

    repo.events.add(
      MatchEventOpCode.matchWelcome.parseIncomingEvent(
        _data(MatchEventOpCode.matchWelcome, 1, _state(0, 0)),
      ),
    );
    repo.events.add(
      MatchEventOpCode.matchStarted.parseIncomingEvent(
        _data(MatchEventOpCode.matchStarted, 1, _state(1, 0)),
      ),
    );

    // Pre-build the raw messages so only the client-side work is timed.
    const total = _matchSeconds * _eventsPerSecond;
    final ops = [
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerJumped,
      MatchEventOpCode.playerScored,
      MatchEventOpCode.playerCorrectPosition,
    ];
    final raw = [
      for (var i = 0; i < total; i++)
        (
          ops[i % ops.length],
          _data(
            ops[i % ops.length],
            1 + i % (_players - 1),
            _state(1, (i + 1) ~/ ops.length),
          ),
        ),
    ];

    final perSecondMs = <double>[];
    final sw = Stopwatch()..start();
    for (var s = 0; s < _matchSeconds; s++) {
      final secondSw = Stopwatch()..start();
      for (var e = 0; e < _eventsPerSecond; e++) {
        final (op, data) = raw[s * _eventsPerSecond + e];
        repo.events.add(op.parseIncomingEvent(data));
      }
      // Let the stream listeners (the game and the widgets) run.
      await Future<void>.delayed(Duration.zero);
      perSecondMs.add(secondSw.elapsedMicroseconds / 1000);
    }
    sw.stop();

    final first10 = perSecondMs.take(10).reduce((a, b) => a + b) / 10;
    final last10 =
        perSecondMs.skip(_matchSeconds - 10).reduce((a, b) => a + b) / 10;
    // ignore: avoid_print
    print(
      'BENCH multiplayer_traffic: events=$total emits=$emits '
      'pageBuilds=$pageBuilds scoreboardBuilds=$scoreboardBuilds '
      'totalMs=${(sw.elapsedMicroseconds / 1000).toStringAsFixed(1)} '
      'msPerGameSecond(first10)=${first10.toStringAsFixed(2)} '
      'msPerGameSecond(last10)=${last10.toStringAsFixed(2)}',
    );
    expect(cubit.state.matchState, isNotNull);

    await sub.cancel();
    await cubit.close();
  });
}
