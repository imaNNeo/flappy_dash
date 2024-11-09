import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

class SpawningPortal extends PositionComponent with HasGameRef<FlappyDashGame> {
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _portalSprite = await game.loadSprite('portal.png');
    _paint = Paint()
      ..colorFilter = ColorFilter.mode(
        color,
        BlendMode.srcIn,
      );
    scale = Vector2.zero();
    _show();

    add(TimerComponent(
      period: hideAfter,
      onTick: () {
        onHide();
        _hide();
      },
      removeOnFinish: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += rotationSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _portalSprite.render(
      canvas,
      size: size,
      overridePaint: _paint,
    );
  }

  void _show() {
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(
        duration: 0.5,
        curve: Curves.easeOutCubic,
      ),
    ));
  }

  void _hide() {
    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(
        duration: 0.5,
        curve: Curves.easeOutCubic,
        onMax: removeFromParent,
      ),
    ));
  }
}
