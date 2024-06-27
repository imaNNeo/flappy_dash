import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_dash/components/dash.dart';
import 'package:flappy_dash/components/pipe_pair.dart';

import 'components/parallax_background.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld> {
  FlappyDashGame()
      : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 800,
            height: 1000,
          ),
        );
}

class FlappyDashWorld extends World
    with HasGameRef<FlappyDashGame>, TapCallbacks {
  late Dash player;

  bool isStarted = false;
  static const pipeGap = 240.0;

  @override
  Future<void> onLoad() async {
    await add(ParallaxBackground());
    await add(player = Dash(position: Vector2.zero()));
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.jump();
    if (!isStarted) {
      _startGame();
    }
  }

  void _startGame() async {
    isStarted = true;
    final gameSize = gameRef.size;
    final pipesMinSize = gameSize.y * 0.25;
    final available = (gameSize.y - (pipesMinSize * 2));
    final startPos = gameSize.x / 2;
    for (int i = 0; i < 300; i++) {
      final randomVertical =
          (Random().nextDouble() * available) - (available / 2);
      await add(
        PipePair(
          gap: pipeGap,
          position: Vector2(
            startPos + 400.0 * i,
            randomVertical,
          ),
        ),
      );
    }
  }
}
