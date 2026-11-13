// Times Flame's collision detection for the pipes the game keeps alive
// (6 pairs: 2 pipes + 1 hidden coin each) and a dash flying through them,
// with the pipes' hitboxes active (before) and passive (now).
//
//   flutter test test/perf/collision_benchmark_test.dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _Box extends PositionComponent {
  _Box(Vector2 position, Vector2 size, this.type)
    : super(position: position, size: size);
  final CollisionType type;

  @override
  Future<void> onLoad() async => add(RectangleHitbox(collisionType: type));
}

class _Dash extends PositionComponent with CollisionCallbacks {
  _Dash() : super(size: Vector2.all(80), anchor: Anchor.center);
  int hits = 0;

  @override
  Future<void> onLoad() async => add(CircleHitbox(radius: 30));

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    hits++;
  }
}

class _Game extends FlameGame with HasCollisionDetection {}

Future<(double, int)> _run(CollisionType pipeType) async {
  final game = await initializeGame(_Game.new);
  game.onGameResize(Vector2(600, 1000));
  final dash = _Dash();
  await game.world.ensureAdd(dash);
  for (var i = 0; i < 6; i++) {
    final x = 420.0 * (i + 1);
    await game.world.ensureAddAll([
      _Box(Vector2(x, 120), Vector2(82, 752), pipeType),
      _Box(Vector2(x, -872), Vector2(82, 752), pipeType),
      _Box(Vector2(x + 30, -108), Vector2(40, 216), CollisionType.passive),
    ]);
  }
  game.update(0);
  const frames = 20000;
  final sw = Stopwatch()..start();
  for (var f = 0; f < frames; f++) {
    dash.position.setValues((f * 2.7) % 2600, ((f % 300) - 150) * 1.0);
    game.update(1 / 60);
  }
  sw.stop();
  return (sw.elapsedMicroseconds / frames, dash.hits);
}

void main() {
  test('pipes: active vs passive hitboxes', () async {
    await _run(CollisionType.active); // warm up
    final (activeUs, activeHits) = await _run(CollisionType.active);
    final (passiveUs, passiveHits) = await _run(CollisionType.passive);
    // ignore: avoid_print
    print(
      'BENCH collisions: active=${activeUs.toStringAsFixed(1)}us/frame '
      'passive=${passiveUs.toStringAsFixed(1)}us/frame '
      'dashHits active=$activeHits passive=$passiveHits',
    );
    // The dash must see exactly the same collisions either way.
    expect(passiveHits, activeHits);
  });
}
