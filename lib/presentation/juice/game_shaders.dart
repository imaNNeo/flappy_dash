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

  static Future<FragmentProgram?> _tryLoad(String asset) async {
    try {
      return await FragmentProgram.fromAsset(asset);
    } catch (e) {
      debugPrint('Could not load shader $asset: $e');
      return null;
    }
  }
}
