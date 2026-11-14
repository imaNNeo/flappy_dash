import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'game_shaders.dart';

/// Whole-screen effects: trauma based screen shake and the shockwave
/// overlay. [FlappyDashGame.renderTree] calls [render].
///
/// The shockwave is drawn on top of the frame with [GameShaders.shockwave];
/// it never reads the frame back (on the web that is a GPU→CPU copy that
/// stalls every frame it's used).
class ScreenFx {
  /// 0..1, decays over time. Shake is trauma², so small hits barely move the
  /// screen and big ones really kick.
  double _trauma = 0;
  double _time = 0;

  static const _maxShakeOffset = 22.0;
  static const _traumaDecayPerSecond = 1.6;

  _Shockwave? _wave;

  ui.FragmentShader? _shader;

  void shake(double amount) {
    _trauma = min(1, _trauma + amount);
  }

  /// A small ring around [center]; both [center] and [radius] are in
  /// screen (canvas) pixels.
  void shockwave(
    Offset center, {
    required double radius,
    double strength = 1,
    double duration = 0.45,
  }) {
    _wave = _Shockwave(center, radius, strength, duration);
  }

  bool get isShaking => _trauma > 0;

  void update(double dt) {
    _time += dt;
    _trauma = max(0, _trauma - _traumaDecayPerSecond * dt);
    final wave = _wave;
    if (wave != null) {
      wave.elapsed += dt;
      if (wave.elapsed >= wave.duration) {
        _wave = null;
      }
    }
  }

  void render(ui.Canvas canvas, Vector2 size, void Function(ui.Canvas) draw) {
    _renderShaken(canvas, size, draw);
    final wave = _wave;
    final program = GameShaders.shockwave;
    if (wave == null || program == null || size.x <= 0 || size.y <= 0) {
      return;
    }
    final shader = _shader ??= program.fragmentShader();
    final progress = (wave.elapsed / wave.duration).clamp(0.0, 1.0);
    final side = wave.radius * 2;
    shader
      ..setFloat(0, side)
      ..setFloat(1, side)
      ..setFloat(2, progress)
      ..setFloat(3, wave.strength);
    // Only the square around the ring is drawn.
    canvas.save();
    canvas.translate(
      wave.center.dx - wave.radius,
      wave.center.dy - wave.radius,
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, side, side),
      _paint..shader = shader,
    );
    canvas.restore();
  }

  final ui.Paint _paint = ui.Paint();

  void _renderShaken(
    ui.Canvas canvas,
    Vector2 size,
    void Function(ui.Canvas) draw,
  ) {
    if (_trauma <= 0) {
      draw(canvas);
      return;
    }
    final shake = _trauma * _trauma;
    // Smooth-ish noise from a few sines (cheaper than Perlin, no allocations).
    double noise(double seed) =>
        sin(_time * 47 + seed) * 0.6 + sin(_time * 83 + seed * 2.3) * 0.4;
    final dx = _maxShakeOffset * shake * noise(1.7);
    final dy = _maxShakeOffset * shake * noise(5.1);
    // No rotation: a rotated canvas turns the camera's clip into an
    // anti-aliased rotated clip, and on the web every kind of draw then
    // needs a new GPU program (a burst of compiles, a visible hitch).
    canvas.save();
    canvas.translate(size.x / 2 + dx, size.y / 2 + dy);
    // Zoom in a touch so the shaken edges don't show the letterbox.
    final zoom = 1 + 0.04 * shake;
    canvas.scale(zoom);
    canvas.translate(-size.x / 2, -size.y / 2);
    draw(canvas);
    canvas.restore();
  }
}

class _Shockwave {
  _Shockwave(this.center, this.radius, this.strength, this.duration);

  final Offset center;
  final double radius;
  final double strength;
  final double duration;
  double elapsed = 0;
}
