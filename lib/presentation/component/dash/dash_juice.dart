import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// The purely cosmetic motion of a dash's body: tilt from its vertical
/// velocity, a squash/stretch spring on each jump, a hover bob while idle, a
/// white hit flash and a cartoon tumble off the screen when it dies, and a
/// pop-in when it respawns.
///
/// None of this touches the dash's position or physics (which the server
/// owns in multiplayer); it only transforms the canvas while the body is
/// drawn, so the name above the dash stays upright.
class DashJuice {
  // Tilt.
  double _angle = 0;
  static const _maxNoseUp = -0.45;
  static const _maxNoseDown = 1.1;

  // Squash and stretch: a damped spring around 0. Positive stretches the
  // body tall and thin, negative squashes it short and wide.
  double _stretch = 0;
  double _stretchVelocity = 0;
  static const _springStiffness = 520.0;
  static const _springDamping = 14.0;

  // Idle hover.
  double _time = 0;
  bool idle = false;

  // Death: knocked up, then tumbles down out of the screen.
  double _flash = 0;
  double _deathTime = -1;
  double _fallY = 0;
  double _fallVelocity = 0;
  double _spin = 0;
  double _spinDirection = 1;
  static const _tumbleDuration = 1.3;

  // Respawn pop-in.
  double _spawnTime = -1;
  static const _spawnDuration = 0.45;

  bool get isDead => _deathTime >= 0;

  /// Still falling after dying, so worth drawing.
  bool get isTumbling => isDead && _deathTime < _tumbleDuration;

  bool get isGone => isDead && !isTumbling;

  void onJump() {
    // Kick the spring: stretch up with the jump, then wobble back.
    _stretch = 0.22;
    _stretchVelocity = 2.5;
  }

  /// A little squash, used when scoring so the dash reacts.
  void onScore() {
    _stretchVelocity -= 3.5;
  }

  void onDie() {
    if (isDead) {
      return;
    }
    _flash = 1;
    _deathTime = 0;
    _stretch = -0.3;
    _stretchVelocity = 0;
    _fallY = 0;
    _fallVelocity = -420;
    _spin = _angle;
    // Spin backwards when diving, forwards when climbing.
    _spinDirection = _angle > 0.2 ? -1 : 1;
  }

  void onRespawn() {
    _deathTime = -1;
    _flash = 0;
    _fallY = 0;
    _fallVelocity = 0;
    _angle = 0;
    _stretch = 0;
    _stretchVelocity = 0;
    _spawnTime = 0;
  }

  void update(double dt, double velocityY) {
    _time += dt;
    if (_deathTime >= 0) {
      _deathTime += dt;
      _fallVelocity += 2200 * dt;
      _fallY += _fallVelocity * dt;
      _spin += _spinDirection * 9 * dt;
    }
    if (_spawnTime >= 0) {
      _spawnTime += dt;
      if (_spawnTime >= _spawnDuration) {
        _spawnTime = -1;
      }
    }
    _flash = max(0, _flash - dt * 9);

    // Ease toward the velocity's angle: snappy when nosing up after a jump,
    // lazier when tipping into a dive.
    final target = idle
        ? sin(_time * 3) * 0.06
        : (velocityY * 0.0012).clamp(_maxNoseUp, _maxNoseDown);
    final rate = target < _angle ? 18.0 : 5.0;
    _angle += (target - _angle) * (1 - exp(-rate * dt));

    // Semi-implicit Euler is stable enough at these stiffnesses, but a big
    // hitch could still blow it up, so sub-step long frames.
    var remaining = min(dt, 0.1);
    while (remaining > 0) {
      final step = min(remaining, 1 / 120);
      remaining -= step;
      final accel =
          -_springStiffness * _stretch - _springDamping * _stretchVelocity;
      _stretchVelocity += accel * step;
      _stretch += _stretchVelocity * step;
    }
  }

  final Paint _flashPaint = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0xFFFFFFFF),
      BlendMode.srcATop,
    );
  final Paint _fadePaint = Paint();

  /// Draws the body with [drawBody], transformed around its center.
  void renderBody(Canvas canvas, Vector2 size, void Function(Canvas) drawBody) {
    if (isGone) {
      return;
    }
    final cx = size.x / 2;
    final cy = size.y / 2;

    var scaleX = 1 - _stretch * 0.8;
    var scaleY = 1 + _stretch;
    var opacity = 1.0;

    if (_spawnTime >= 0) {
      // Elastic pop-in.
      final t = _spawnTime / _spawnDuration;
      final s = _elasticOut(t);
      scaleX *= s;
      scaleY *= s;
    }
    final dead = _deathTime >= 0;
    if (dead) {
      final t = _deathTime / _tumbleDuration;
      opacity = (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0);
    }

    final bob = idle && !dead ? sin(_time * 4) * 6 : 0.0;

    canvas.save();
    canvas.translate(cx, cy + bob + (dead ? _fallY : 0));
    canvas.rotate(dead ? _spin : _angle);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-cx, -cy);

    final needsLayer = _flash > 0 || opacity < 1;
    if (needsLayer) {
      _fadePaint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas.saveLayer(null, _fadePaint);
    }
    drawBody(canvas);
    if (_flash > 0) {
      // Paint the body white, fading back to its colors.
      canvas.saveLayer(
        null,
        _flashPaint..color = Color.fromRGBO(255, 255, 255, _flash),
      );
      drawBody(canvas);
      canvas.restore();
    }
    if (needsLayer) {
      canvas.restore();
    }
    canvas.restore();
  }

  static double _elasticOut(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    const c4 = (2 * pi) / 3;
    return pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1;
  }
}
