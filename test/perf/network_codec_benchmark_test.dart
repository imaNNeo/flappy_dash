// Compares how the client used to handle each network message on mobile and
// desktop (a new isolate per message, and one parse per listener) with how it
// handles them now (in place, parsed once).
//
//   flutter test test/perf/network_codec_benchmark_test.dart
import 'dart:convert';
import 'dart:isolate';

import 'package:flappy_dash/data/remote/match_event_op_code.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/netcode/net_protocol.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nakama/nakama.dart';

const _messages = 600; // ~10 seconds of a 20-player match

String _id(int i) =>
    '${i.toString().padLeft(8, '0')}-0000-4000-8000-000000000000';

MatchData _message(int i) => MatchData(
  matchId: 'm',
  opCode: MatchEventOpCode.playerScored.opCode,
  presence: UserPresence(
    userId: _id(1),
    sessionId: _id(2),
    username: 'p',
    persistence: false,
  ),
  reliable: true,
  data: utf8.encode(
    jsonEncode({
      'matchInitializedAt': 0,
      'matchRunsAt': 0,
      'matchFinishesAt': 0,
      'currentPhase': 1,
      'presences': [
        for (var p = 0; p < 20; p++)
          {'userId': _id(p), 'sessionId': _id(p + 50), 'username': 'u$p'},
      ],
      'players': {
        for (var p = 0; p < 20; p++)
          _id(p): {
            'userId': _id(p),
            'displayName': 'Player $p',
            'isInLobby': true,
            'lastKnownX': 1234.56 + i,
            'lastKnownY': -12.34,
            'lastKnownVelocityY': -500,
            'score': p,
            'playingState': 1,
            'spawnsAgainAt': 0,
          },
      },
      'pipesPositions': [for (var p = 0; p < 20; p++) 0.1234],
    }),
  ),
);

MatchEvent _parse(MatchData data) =>
    MatchEventOpCode.fromOpCode(data.opCode)!.parseIncomingEvent(data);

void main() {
  test('incoming: compute() per listener vs one in-place parse', () async {
    final messages = [for (var i = 0; i < _messages; i++) _message(i)];

    // Before: each of the two listeners (game cubit + ping) ran compute().
    final before = Stopwatch()..start();
    for (final m in messages) {
      final a = await compute(_parse, m);
      await compute(_parse, m);
      // The game reads the match state of (almost) every event.
      (a as HasMatchState).state;
    }
    before.stop();

    final after = Stopwatch()..start();
    for (final m in messages) {
      final e = _parse(m);
      (e as HasMatchState).state;
    }
    after.stop();

    // ignore: avoid_print
    print(
      'BENCH incoming: before=${(before.elapsedMicroseconds / _messages).toStringAsFixed(0)}us/msg '
      'after=${(after.elapsedMicroseconds / _messages).toStringAsFixed(0)}us/msg',
    );
  });

  test('outgoing: Isolate.run per event vs in-place encode', () async {
    final events = [
      for (var i = 0; i < _messages; i++)
        DispatchingPlayerInputEvent(
          InputPacket(
            lifeStartSeq: 100,
            upToSeq: 100 + i,
            jumpSeqs: [i, i + 1],
          ),
        ),
    ];
    final before = Stopwatch()..start();
    for (final e in events) {
      await Isolate.run(() => e.toBytes());
    }
    before.stop();
    final after = Stopwatch()..start();
    for (final e in events) {
      e.toBytes();
    }
    after.stop();
    // ignore: avoid_print
    print(
      'BENCH outgoing: before=${(before.elapsedMicroseconds / _messages).toStringAsFixed(0)}us/msg '
      'after=${(after.elapsedMicroseconds / _messages).toStringAsFixed(1)}us/msg',
    );
  });
}
