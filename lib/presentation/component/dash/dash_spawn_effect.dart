import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'dash.dart';

class DashSpawnEffect extends ComponentEffect<Dash> {
  DashSpawnEffect({
    super.onComplete,
})
      : super(EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
        ));

  final scaleFrom = Vector2(0.0, 0.0);
  final scaleTo = Vector2.all(1.0);
  final rotationTurns = 2.0;

  @override
  void apply(double progress) {
    target.scale = scaleFrom * (1 - progress) + scaleTo * progress;
    target.angle = pi * 2 * rotationTurns * progress;
  }

  @override
  void onFinish() {
    super.onFinish();
    removeFromParent();
  }
}
