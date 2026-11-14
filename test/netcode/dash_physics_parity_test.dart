// Checks the Dart dash simulation against trajectories computed by the
// server's TypeScript simulation (flappy_dash_nakama/tests/physics), bit for
// bit. If this passes, client-side prediction lands exactly where the server
// does. Regenerate physics_golden.json there after a deliberate change.
import 'dart:convert';
import 'dart:io';

import 'package:flappy_dash/domain/netcode/dash_physics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final scenarios = jsonDecode(
    File('test/netcode/physics_golden.json').readAsStringSync(),
  ) as List;

  for (final scenario in scenarios.cast<Map<String, dynamic>>()) {
    test('same trajectory as the server: ${scenario['name']}', () {
      final pipes = (scenario['pipesPositions'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
      final sim = DashSim.spawn(
        (scenario['spawnX'] as num).toDouble(),
        (scenario['spawnY'] as num).toDouble(),
        scenario['score'] as int,
      );
      final jumps = (scenario['jumps'] as List).cast<int>().toSet();
      final checkpoints = {
        for (final c in (scenario['checkpoints'] as List).cast<List>())
          c[0] as int: c,
      };
      final events = <List<int>>[];
      final ticks = scenario['ticks'] as int;
      for (var t = 1; t <= ticks && sim.alive; t++) {
        final r = DashPhysics.step(sim, jumps.contains(t), pipes);
        if (r != DashStepResult.none) {
          events.add([t, r == DashStepResult.scored ? 1 : 2]);
        }
        final c = checkpoints[t];
        if (c != null) {
          expect(sim.x, (c[1] as num).toDouble(), reason: 'x at tick $t');
          expect(sim.y, (c[2] as num).toDouble(), reason: 'y at tick $t');
          expect(sim.vy, (c[3] as num).toDouble(), reason: 'vy at tick $t');
          expect(sim.alive, c[4], reason: 'alive at tick $t');
          expect(sim.score, c[5], reason: 'score at tick $t');
          expect(sim.lastScoredPipe, c[6], reason: 'lastScoredPipe at $t');
        }
      }
      expect(events, (scenario['events'] as List).cast<List>());
    });
  }
}
