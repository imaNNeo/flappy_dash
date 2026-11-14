import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'game_shaders.dart';

/// Whole-screen effects: trauma based screen shake and the death
/// shockwave. [FlappyDashGame.renderTree] calls [render].
///
/// The shockwave bends and blurs what's behind it like a lens. It can't read
/// the frame back to do that (on the web, `toImageSync` is a GPU→CPU copy
/// every frame, and it made deaths stutter), so it records the frame as a
/// picture and replays it once, magnified a little around the impact point
/// and seen only through the band of the wave, under a fixed blur. That
/// pushes the scene outward along the wave front as one soft band.
/// [GameShaders.shockwave] adds the faint rim on the wave front.
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

  /// Smoothed frame time. The lens replays the whole frame once more, so on
  /// a device that already struggles it is skipped (the rim still shows).
  double _averageDt = 1 / 60;

  bool get _lensAllowed => _averageDt < 1 / 40;

  void update(double dt) {
    _time += dt;
    if (_wave == null && dt > 0 && dt < 0.5) {
      _averageDt += (dt - _averageDt) * 0.05;
    }
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
    final wave = _wave;
    final warmingUp = wave == null && _lensWarmUpFrames > 0;
    if ((wave == null && !warmingUp) || size.x <= 0 || size.y <= 0) {
      _renderShaken(canvas, size, draw);
      return;
    }
    final recorder = ui.PictureRecorder();
    _renderShaken(ui.Canvas(recorder), size, draw);
    final scene = recorder.endRecording();
    canvas.drawPicture(scene);

    if (wave == null) {
      // Runs the lens over the real scene, almost invisible, so the GPU
      // programs it needs (each kind of draw under the ring clip, the blur)
      // compile while the game loads instead of on the first death.
      _lensWarmUpFrames--;
      final warmWave = _Shockwave(
        Offset(size.x / 2, size.y / 2),
        min(size.x, size.y) / 3,
        1,
        1,
      );
      _renderLens(canvas, scene, warmWave, 0.3, _warmUpLayerPaint);
    } else {
      final progress = (wave.elapsed / wave.duration).clamp(0.0, 1.0);
      if (_lensAllowed) {
        _renderLens(canvas, scene, wave, progress, _blurLayerPaint);
      }
      _renderRim(canvas, wave, progress);
    }
    scene.dispose();
  }

  int _lensWarmUpFrames = 2;

  // Same curve as the rim in shockwave.frag: fast out, then settles.
  static double _waveRadius(double maxRadius, double progress) {
    final eased = 1 - pow(1 - progress, 4).toDouble();
    return (0.15 + 0.85 * eased) * maxRadius * 0.92;
  }

  final ui.Paint _blurLayerPaint = ui.Paint()
    // A fixed blur radius: animating it would build a new blur per radius.
    ..imageFilter = ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  final ui.Paint _warmUpLayerPaint = ui.Paint()
    ..color = const Color(0x02000000)
    ..imageFilter = ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  void _renderLens(
    ui.Canvas canvas,
    ui.Picture scene,
    _Shockwave wave,
    double progress,
    ui.Paint layerPaint,
  ) {
    final maxRadius = wave.radius;
    final radius = _waveRadius(maxRadius, progress);
    final fade = (1 - progress) * wave.strength;
    // The band the wave bends, wide at first and thinning out.
    final bandWidth = (0.34 - 0.24 * progress) * maxRadius;
    // How far the middle of the band is pushed outward.
    final push = 0.22 * maxRadius * fade;
    if (push < 0.3) {
      return;
    }
    final center = wave.center;
    final inner = max(0.0, radius - bandWidth);
    final outer = radius + bandWidth;

    canvas.saveLayer(
      Rect.fromCircle(center: center, radius: outer + 8),
      layerPaint,
    );
    // One magnified copy of the scene, seen only through the band: what
    // shows at the wave front comes from `radius - push`. The blur on the
    // layer softens the band's edges into a smooth bend.
    final scale = radius / max(1.0, radius - push);
    final ring = ui.Path()
      ..fillType = ui.PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: center, radius: outer))
      ..addOval(Rect.fromCircle(center: center, radius: inner));
    canvas.clipPath(ring);
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPicture(scene);
    canvas.restore();
  }

  void _renderRim(ui.Canvas canvas, _Shockwave wave, double progress) {
    final program = GameShaders.shockwave;
    if (program == null) {
      return;
    }
    final shader = _shader ??= program.fragmentShader();
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
