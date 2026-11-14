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
import 'package:flappy_dash/domain/netcode/net_protocol.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nakama/nakama.dart';

const _players = 20;
const _matchSeconds = 120;
// With the server-authoritative netcode a player receives 20 snapshots per
// second plus the score/death events (~8 per second at 20 players).
const _snapshotsPerSecond = 20;
const _scoresPerSecond = 8;
const _eventsPerSecond = _snapshotsPerSecond + _scoresPerSecond;
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

MatchData _snapshot(int n) {
  final data = ByteData(Snapshot.headerSize + _players * Snapshot.entrySize);
  data.setUint8(0, 0);
  data.setUint32(1, n * 50, Endian.little);
  data.setUint8(5, _players);
  for (var i = 0; i < _players; i++) {
    final o = Snapshot.headerSize + i * Snapshot.entrySize;
    data.setUint8(o, i);
    data.setUint8(o + 1, 1);
    data.setUint32(o + 4, n * 3, Endian.little);
    data.setFloat32(o + 8, n * 8.0 + i, Endian.little);
    data.setFloat32(o + 12, (i * 13 % 200) - 100.0, Endian.little);
  }
  return MatchData(
    matchId: _matchId,
    opCode: MatchEventOpCode.matchSnapshot.opCode,
    data: data.buffer.asUint8List(),
    reliable: true,
  );
}

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
    final raw = [
      for (var i = 0; i < total; i++)
        i % _eventsPerSecond < _snapshotsPerSecond
            ? (MatchEventOpCode.matchSnapshot, _snapshot(i))
            : (
                MatchEventOpCode.playerScored,
                _data(
                  MatchEventOpCode.playerScored,
                  1 + i % (_players - 1),
                  _state(1, i ~/ _eventsPerSecond),
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
