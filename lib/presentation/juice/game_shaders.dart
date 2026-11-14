import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The game's fragment shaders (see /shaders), loaded once.
///
/// Every effect that uses one checks for null and simply skips the shader
/// part when it couldn't be loaded, so a device without shader support still
/// plays fine.
class GameShaders {
  GameShaders._();

  static FragmentProgram? shockwave;
  static FragmentProgram? scoreBurst;
  static FragmentProgram? portal;

  static Future<void>? _loading;

  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    shockwave = await _tryLoad('shaders/shockwave.frag');
    scoreBurst = await _tryLoad('shaders/score_burst.frag');
    portal = await _tryLoad('shaders/portal.frag');
  }

  /// Draws every shader once, invisibly, so the GPU compiles them while the
  /// game loads instead of on the first score or death (a visible hitch,
  /// especially on the web). Call it from the first frames' render.
  static void warmUp(Canvas canvas) {
    // Once as drawn on the screen, once under a fractional scale like the
    // game world's (which draws with anti-aliased edges, another program).
    _warmUp(canvas);
    canvas.save();
    canvas.translate(0.5, 0.5);
    canvas.scale(0.7);
    _warmUp(canvas);
    canvas.restore();
  }

  static void _warmUp(Canvas canvas) {
    _warmUpPaint ??= Paint();
    final paint = _warmUpPaint!;
    // Every shader is fully transparent at these inputs (progress 1, a
    // pixel far from the center), but the GPU doesn't know that.
    const rect = Rect.fromLTWH(0, 0, 1, 1);
    final shockwave = GameShaders.shockwave?.fragmentShader();
    if (shockwave != null) {
      shockwave
        ..setFloat(0, 100)
        ..setFloat(1, 100)
        ..setFloat(2, 50)
        ..setFloat(3, 50)
        ..setFloat(4, 1)
        ..setFloat(5, 0);
      canvas.drawRect(rect, paint..shader = shockwave);
    }
    final burst = GameShaders.scoreBurst?.fragmentShader();
    if (burst != null) {
      for (var i = 0; i < 8; i++) {
        burst.setFloat(i, i < 2 ? 100 : (i == 2 ? 1 : 0));
      }
      canvas.drawRect(rect, paint..shader = burst);
    }
    final portal = GameShaders.portal?.fragmentShader();
    if (portal != null) {
      for (var i = 0; i < 7; i++) {
        portal.setFloat(i, i < 2 ? 100 : 0);
      }
      canvas.drawRect(rect, paint..shader = portal);
    }
    paint.shader = null;
    // The dash's white hit flash is a color-filtered layer.
    canvas.saveLayer(
      rect,
      Paint()
        ..colorFilter = const ColorFilter.mode(
          Color(0xFFFFFFFF),
          BlendMode.srcATop,
        ),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0x01000000));
    canvas.restore();
  }

  static Paint? _warmUpPaint;

  static Future<FragmentProgram?> _tryLoad(String asset) async {
    try {
      return await FragmentProgram.fromAsset(asset);
    } catch (e) {
      debugPrint('Could not load shader $asset: $e');
      return null;
    }
  }
}
