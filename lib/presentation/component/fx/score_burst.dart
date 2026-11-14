import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flappy_dash/presentation/component/outlined_text_component.dart';
import 'package:flappy_dash/presentation/juice/game_shaders.dart';
import 'package:flutter/material.dart' show Curves, FontWeight, TextStyle;

/// The burst where a point is scored: a sparkle shader ([GameShaders.scoreBurst])
/// and a "+1" that pops up and floats away.
class ScoreBurst extends PositionComponent {
  ScoreBurst({
    required super.position,
    required this.color,
    this.showPlusOne = true,
    super.priority,
  }) : super(anchor: Anchor.center, size: Vector2.all(_burstSize));

  static const _burstSize = 220.0;
  static const _lifetime = 0.55;
  static const _textLifetime = 0.8;

  final Color color;
  final bool showPlusOne;
  double _time = 0;
  final double _seed = Random().nextDouble() * pi;

  FragmentShader? _shader;
  final Paint _paint = Paint();
  OutlinedTextComponent? _text;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _shader = GameShaders.scoreBurst?.fragmentShader();
    if (showPlusOne) {
      add(
        _text = OutlinedTextComponent(
          text: '+1',
          position: Vector2(size.x / 2 + 30, size.y / 2 - 30),
          strokeWidth: 6,
          textStyle: TextStyle(
            fontSize: 52,
            fontFamily: 'Chewy',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: color,
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_time >= max(_lifetime, showPlusOne ? _textLifetime : 0)) {
      removeFromParent();
      return;
    }
    final text = _text;
    if (text != null) {
      final t = (_time / _textLifetime).clamp(0.0, 1.0);
      // Pop in with overshoot, float up, shrink away at the end.
      final pop = Curves.elasticOut.transform((t / 0.45).clamp(0.0, 1.0));
      final shrink =
          1 - Curves.easeIn.transform(((t - 0.7) / 0.3).clamp(0.0, 1.0));
      text.scale.setAll(pop * shrink);
      text.position.y = size.y / 2 - 30 - 70 * Curves.easeOut.transform(t);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final shader = _shader;
    if (shader == null || _time >= _lifetime) {
      return;
    }
    final progress = _time / _lifetime;
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, progress)
      ..setFloat(3, color.r)
      ..setFloat(4, color.g)
      ..setFloat(5, color.b)
      ..setFloat(6, 1)
      ..setFloat(7, _seed);
    _paint.shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }

  @override
  void onRemove() {
    _shader?.dispose();
    super.onRemove();
  }
}
