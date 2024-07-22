import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'component/dash.dart';
import 'component/dash_parallax_background.dart';
import 'component/pipe_pair.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld>
    with KeyboardEvents, HasCollisionDetection {
  FlappyDashGame()
      : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 600,
            height: 1000,
          ),
        );

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      world.onSpaceDown();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class FlappyDashWorld extends World
    with TapCallbacks, HasGameRef<FlappyDashGame> {
  late Dash _dash;
  late PipePair _lastPipe;
  static const _pipesDistance = 400.0;
  int _score = 0;
  late TextComponent _scoreText;

  @override
  void onLoad() {
    super.onLoad();
    add(DashParallaxBackground());
    add(_dash = Dash());
    _generatePipes(
      fromX: 350,
    );
    game.camera.viewfinder.add(
      _scoreText = TextComponent(
        text: _score.toString(),
        position: Vector2(0, -(game.size.y / 2)),
      ),
    );
  }

  void _generatePipes({
    int count = 5,
    double fromX = 0.0,
  }) {
    for (int i = 0; i < count; i++) {
      const area = 600;
      final y = (Random().nextDouble() * area) - (area / 2);
      add(_lastPipe = PipePair(
        position: Vector2(fromX + (i * _pipesDistance), y),
      ));
    }
  }

  void _removePipes() {
    final pipes = children.whereType<PipePair>();
    final shouldBeRemoved = max(pipes.length - 5, 0);
    pipes.take(shouldBeRemoved).forEach((pipe) {
      pipe.removeFromParent();
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _dash.jump();
  }

  void onSpaceDown() {
    _dash.jump();
  }

  void increaseScore() {
    _score += 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scoreText.text = _score.toString();
    if (_dash.x >= _lastPipe.x) {
      _generatePipes(
        fromX: _pipesDistance,
      );
      _removePipes();
    }
    game.camera.viewfinder.zoom = 1.0;
  }
}
