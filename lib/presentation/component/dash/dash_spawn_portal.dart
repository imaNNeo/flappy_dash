import 'dart:ui' show FragmentShader;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/juice/game_shaders.dart';
import 'package:flutter/material.dart';

class SpawningPortal extends PositionComponent
    with HasGameReference<FlappyDashGame> {
  SpawningPortal({
    required super.position,
    required super.size,
    required this.color,
    required this.hideAfter,
    required this.onHide,
    this.rotationSpeed = 8.0,
    super.priority,
  }) : super(anchor: Anchor.center);

  final Color color;
  late final Paint _paint;
  final double rotationSpeed;
  late final Sprite _portalSprite;
  final double hideAfter;
  final VoidCallback onHide;

  // Swirling vortex behind the portal ring (GameShaders.portal).
  FragmentShader? _vortex;
  final Paint _vortexPaint = Paint();
  double _time = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _portalSprite = await game.loadSprite('portal.png');
    _paint = Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);
    _vortex = GameShaders.portal?.fragmentShader();
    scale = Vector2.zero();
    _show();

    add(
      TimerComponent(
        period: hideAfter,
        onTick: () {
          onHide();
          _hide();
        },
        removeOnFinish: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += rotationSpeed * dt;
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final vortex = _vortex;
    if (vortex != null) {
      // The component spins; counter-rotate so the swirl keeps its own pace.
      final vortexSize = size.x * 1.25;
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(-angle);
      canvas.translate(-vortexSize / 2, -vortexSize / 2);
      vortex
        ..setFloat(0, vortexSize)
        ..setFloat(1, vortexSize)
        ..setFloat(2, _time)
        ..setFloat(3, color.r)
        ..setFloat(4, color.g)
        ..setFloat(5, color.b)
        ..setFloat(6, 1);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, vortexSize, vortexSize),
        _vortexPaint..shader = vortex,
      );
      canvas.restore();
    }
    _portalSprite.render(canvas, size: size, overridePaint: _paint);
  }

  @override
  void onRemove() {
    _vortex?.dispose();
    super.onRemove();
  }

  void _show() {
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _hide() {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
          onMax: removeFromParent,
        ),
      ),
    );
  }
}
