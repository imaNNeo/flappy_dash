import 'dart:typed_data';

import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/netcode/dash_physics.dart';
import 'package:flappy_dash/domain/netcode/dash_predictor.dart';
import 'package:flappy_dash/domain/netcode/net_protocol.dart';
import 'package:flappy_dash/domain/netcode/remote_dash_interpolator.dart';
import 'package:flutter_test/flutter_test.dart';

final _pipes = [0.1, -0.3, 0.25, -0.05, 0.4];

double _f32(double v) => (Float32List(1)..[0] = v)[0];

/// The server's side of one player, as in multi_dash_handler.ts.
class _FakeServer {
  _FakeServer(double x, double y) : sim = DashSim.spawn(x, y, 0);

  final DashSim sim;
  int lastSeq = 0;
  int lifeStart = -1;
  final Set<int> jumps = {};
  bool dropJumps = false;

  void receive(InputPacket p) {
    if (lifeStart != p.lifeStartSeq) {
      lifeStart = p.lifeStartSeq;
      lastSeq = p.lifeStartSeq - 1;
    }
    if (!dropJumps) {
      jumps.addAll(p.jumpSeqs.where((j) => j > lastSeq));
    }
    while (lastSeq < p.upToSeq && sim.alive) {
      lastSeq++;
      DashPhysics.step(sim, jumps.contains(lastSeq), _pipes);
    }
  }

  SnapshotEntry entry() => SnapshotEntry(
    rosterIndex: 0,
    playingState: sim.alive ? PlayingState.playing : PlayingState.gameOver,
    score: sim.score,
    seq: lastSeq,
    x: _f32(sim.x),
    y: _f32(sim.y),
    vy: _f32(sim.vy),
    lastScoredPipe: sim.lastScoredPipe,
  );
}

/// Runs a client and a server with [latencyTicks] of one-way latency.
({DashPredictor predictor, _FakeServer server}) _play({
  required int latencyTicks,
  required int ticks,
  bool serverDropsJumps = false,
}) {
  final predictor = DashPredictor(_pipes);
  final server = _FakeServer(420, 0)..dropJumps = serverDropsJumps;
  predictor.startLife(420, 0, 0);
  final toServer = <int, List<InputPacket>>{};
  final toClient = <int, List<SnapshotEntry>>{};
  for (var t = 0; t < ticks; t++) {
    // A simple pilot that keeps the dash around the gaps.
    final sim = predictor.sim!;
    final next = ((sim.x - 60) / DashPhysics.pipesDistance).floor() + 1;
    final target = DashPhysics.pipeGapCenterY(_pipes, next) + 25;
    final jump = sim.vy > 150 && sim.y > target;
    predictor.tick(jump);
    final packet = predictor.pollInputPacket();
    if (packet != null) {
      (toServer[t + latencyTicks] ??= []).add(packet);
    }
    for (final p in toServer.remove(t) ?? <InputPacket>[]) {
      server.receive(p);
    }
    // The server sends a snapshot every 3 ticks (20 per second).
    if (t % 3 == 0) {
      (toClient[t + latencyTicks] ??= []).add(server.entry());
    }
    for (final e in toClient.remove(t) ?? <SnapshotEntry>[]) {
      predictor.reconcile(e);
    }
  }
  return (predictor: predictor, server: server);
}

void main() {
  group('DashPredictor', () {
    test('never corrects when the server agrees, whatever the latency', () {
      for (final latency in [0, 3, 9, 18]) {
        final r = _play(latencyTicks: latency, ticks: 1200);
        expect(r.predictor.corrections, 0, reason: 'latency $latency');
        expect(r.predictor.isAlive, isTrue, reason: 'latency $latency');
        expect(r.predictor.sim!.score, greaterThan(5));
        expect(r.server.sim.score, greaterThanOrEqualTo(5));
      }
    });

    test('follows the server when it disagrees', () {
      // The server ignores all jumps: it lets the dash fall and die.
      final r = _play(latencyTicks: 6, ticks: 300, serverDropsJumps: true);
      expect(r.predictor.corrections, greaterThan(0));
      expect(r.predictor.isAlive, isFalse);
    });

    test('heartbeats every 3 ticks, jumps right away', () {
      final p = DashPredictor(_pipes)..startLife(420, 0, 0);
      p.tick(false);
      expect(p.pollInputPacket(), isNull);
      p.tick(true);
      final jumpPacket = p.pollInputPacket()!;
      expect(jumpPacket.upToSeq, p.seq);
      expect(jumpPacket.jumpSeqs, [p.seq]);
      p.tick(false);
      p.tick(false);
      expect(p.pollInputPacket(), isNull);
      p.tick(false);
      // Unacknowledged jumps are repeated.
      expect(p.pollInputPacket()!.jumpSeqs, [jumpPacket.upToSeq]);
    });

    test('input packets survive the wire', () {
      const packet = InputPacket(
        lifeStartSeq: 70000,
        upToSeq: 70123,
        jumpSeqs: [70001, 70100],
      );
      final decoded = InputPacket.fromBytes(packet.toBytes())!;
      expect(decoded.lifeStartSeq, 70000);
      expect(decoded.upToSeq, 70123);
      expect(decoded.jumpSeqs, [70001, 70100]);
    });
  });

  group('RemoteDashInterpolator', () {
    SnapshotEntry entry(int seq, double x, {PlayingState? state}) =>
        SnapshotEntry(
          rosterIndex: 1,
          playingState: state ?? PlayingState.playing,
          score: 0,
          seq: seq,
          x: x,
          y: 0,
          vy: 0,
          lastScoredPipe: 0,
        );

    test('draws the dash between snapshots, a bit in the past', () {
      final i = RemoteDashInterpolator();
      for (var s = 0; s <= 30; s += 3) {
        i.addSnapshotEntry(entry(s, s * 10.0));
      }
      // The playback starts delayTicks behind the newest state.
      i.advance(0);
      final x = i.current()!.x;
      expect(x, closeTo((30 - RemoteDashInterpolator.delayTicks) * 10.0, 1));
      // Half a tick later it moved half a tick, smoothly.
      i.advance(0.5 / 60);
      expect(i.current()!.x, closeTo(x + 5, 0.6));
    });

    test('extrapolates a little when snapshots are late, then holds', () {
      final i = RemoteDashInterpolator()
        ..addSnapshotEntry(entry(0, 0))
        ..addSnapshotEntry(entry(3, 30));
      i.advance(1); // 60 ticks later, nothing new.
      final s = i.current()!;
      final maxX =
          30 +
          DashPhysics.dashStep * RemoteDashInterpolator.maxExtrapolationTicks;
      expect(s.x, closeTo(maxX, 0.01));
    });

    test('shows the death once playback reaches it', () {
      final i = RemoteDashInterpolator();
      for (var s = 0; s <= 30; s += 3) {
        i.addSnapshotEntry(entry(s, s * 10.0));
      }
      i.addSnapshotEntry(entry(31, 310, state: PlayingState.gameOver));
      i.advance(0);
      expect(i.current()!.playingState, PlayingState.playing);
      i.advance(1);
      expect(i.current()!.playingState, PlayingState.gameOver);
    });
  });
}
