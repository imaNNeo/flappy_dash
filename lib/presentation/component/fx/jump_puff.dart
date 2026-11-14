import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A few small air puffs pushed down and back from a dash's wings when it
/// jumps.
class JumpPuff extends PositionComponent {
  JumpPuff({required super.position, Random? random, super.priority})
    : _random = random ?? Random();

  final Random _random;
  final List<_Bubble> _bubbles = [];
  final Paint _paint = Paint();
  double _time = 0;
  static const _lifetime = 0.4;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (var i = 0; i < 4; i++) {
      // Mostly down and to the left (the dash flies to the right).
      final angle = pi * 0.55 + (_random.nextDouble() - 0.3) * 0.9;
      final speed = 90 + _random.nextDouble() * 80;
      _bubbles.add(
        _Bubble(
          x: (_random.nextDouble() - 0.5) * 16,
          y: 18 + _random.nextDouble() * 8,
          vx: cos(angle) * speed - 60,
          vy: sin(angle) * speed,
          radius: 5 + _random.nextDouble() * 6,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_time >= _lifetime) {
      removeFromParent();
      return;
    }
    final drag = exp(-6 * dt);
    for (final b in _bubbles) {
      b.vx *= drag;
      b.vy *= drag;
      b.x += b.vx * dt;
      b.y += b.vy * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Removal happens after this frame is drawn, so _time can already be
    // past the lifetime here. Color.fromRGBO wraps a negative opacity to an
    // almost opaque one, which flashed the puffs for a frame as they vanished.
    final t = _time / _lifetime;
    if (t >= 1) {
      return;
    }
    final fade = 1 - t;
    _paint.color = Color.fromRGBO(255, 255, 255, 0.75 * fade * fade);
    for (final b in _bubbles) {
      canvas.drawCircle(Offset(b.x, b.y), b.radius * (0.6 + 0.8 * t), _paint);
    }
  }
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
  });

  double x, y, vx, vy;
  final double radius;
}
