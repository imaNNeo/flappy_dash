import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Feathers flying out of a dash when it dies, then fluttering down,
/// plus a quick ring of white puffs. All drawn with a couple of cached
/// paths, no images.
class FeatherBurst extends PositionComponent {
  FeatherBurst({
    required super.position,
    required this.color,
    this.count = 18,
    this.scaleFactor = 1,
    Random? random,
    super.priority,
  }) : _random = random ?? Random();

  final Color color;
  final int count;
  final double scaleFactor;
  final Random _random;

  final List<_Feather> _feathers = [];
  final List<_Puff> _puffs = [];
  double _time = 0;
  static const _lifetime = 1.8;

  late final Paint _featherPaint;
  late final Paint _lightFeatherPaint;
  late final Paint _quillPaint;
  final Paint _puffPaint = Paint();

  static final Path _featherPath = _buildFeatherPath();

  static Path _buildFeatherPath() {
    // A leaf-like vane, pointing right, about 26 x 10.
    return Path()
      ..moveTo(-13, 0)
      ..quadraticBezierTo(-4, -7, 13, -1)
      ..quadraticBezierTo(4, 6, -13, 0)
      ..close();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _featherPaint = Paint()..color = color;
    _lightFeatherPaint = Paint()
      ..color = Color.lerp(color, const Color(0xFFFFFFFF), 0.6)!;
    _quillPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = (180 + _random.nextDouble() * 380) * scaleFactor;
      _feathers.add(
        _Feather(
          x: 0,
          y: 0,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 120 * scaleFactor,
          rotation: _random.nextDouble() * pi * 2,
          spin: (_random.nextDouble() - 0.5) * 14,
          swayPhase: _random.nextDouble() * pi * 2,
          swaySpeed: 4 + _random.nextDouble() * 4,
          size: (0.7 + _random.nextDouble() * 0.7) * scaleFactor,
          light: _random.nextBool(),
        ),
      );
    }
    for (var i = 0; i < 8; i++) {
      final angle = i / 8 * pi * 2 + _random.nextDouble() * 0.3;
      _puffs.add(
        _Puff(
          dx: cos(angle),
          dy: sin(angle),
          speed: (140 + _random.nextDouble() * 60) * scaleFactor,
          radius: (10 + _random.nextDouble() * 8) * scaleFactor,
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
    // Feathers: fast burst slowed by strong drag, then they drift down
    // slowly, swaying side to side like real feathers.
    final drag = exp(-3.2 * dt);
    for (final f in _feathers) {
      f.vx *= drag;
      f.vy = f.vy * drag + 260 * dt;
      // Terminal velocity: feathers fall slowly.
      f.vy = min(f.vy, 120.0);
      final sway = sin(_time * f.swaySpeed + f.swayPhase);
      f.x += (f.vx + sway * 60) * dt;
      f.y += f.vy * dt;
      f.rotation += f.spin * dt * (0.3 + 0.7 * drag) + sway * dt * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final t = _time / _lifetime;
    if (t >= 1) {
      return;
    }

    // Puff ring, first 0.35s.
    final puffT = (_time / 0.35).clamp(0.0, 1.0);
    if (puffT < 1) {
      final ease = 1 - pow(1 - puffT, 3).toDouble();
      _puffPaint.color = Color.fromRGBO(255, 255, 255, (1 - puffT) * 0.9);
      for (final p in _puffs) {
        final d = p.speed * 0.35 * ease;
        canvas.drawCircle(
          Offset(p.dx * d, p.dy * d),
          p.radius * (1 - puffT * 0.6),
          _puffPaint,
        );
      }
    }

    // Feathers fade out over the last 40% of their life.
    final alpha = (1 - (t - 0.6) / 0.4).clamp(0.0, 1.0);
    _featherPaint.color = color.withValues(alpha: alpha);
    _lightFeatherPaint.color = _lightFeatherPaint.color.withValues(
      alpha: alpha,
    );
    _quillPaint.color = Color.fromRGBO(255, 255, 255, 0.5 * alpha);
    for (final f in _feathers) {
      canvas.save();
      canvas.translate(f.x, f.y);
      canvas.rotate(f.rotation);
      canvas.scale(f.size);
      canvas.drawPath(
        _featherPath,
        f.light ? _lightFeatherPaint : _featherPaint,
      );
      canvas.drawLine(
        const Offset(-15, 0.5),
        const Offset(11, -0.5),
        _quillPaint,
      );
      canvas.restore();
    }
  }
}

class _Feather {
  _Feather({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.spin,
    required this.swayPhase,
    required this.swaySpeed,
    required this.size,
    required this.light,
  });

  double x, y, vx, vy, rotation;
  final double spin, swayPhase, swaySpeed, size;
  final bool light;
}

class _Puff {
  _Puff({
    required this.dx,
    required this.dy,
    required this.speed,
    required this.radius,
  });

  final double dx, dy, speed, radius;
}
