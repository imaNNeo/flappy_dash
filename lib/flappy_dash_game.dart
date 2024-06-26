import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_dash/components/dash.dart';
import 'package:flappy_dash/components/pipe.dart';

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
  static const pipeGap = 240;

  @override
  Future<void> onLoad() async {
    await add(ParallaxBackground());
    await add(player = Dash(position: Vector2.zero()));
    final gameSize = gameRef.size;

    final pipesMinSize = gameSize.y * 0.25;
    final available = (gameSize.y - (pipesMinSize * 2));
    for (int i = 0; i < 30; i++) {
      final randomVertical =
          (Random().nextDouble() * available) - (available / 2);
      await add(
        Pipe(
          isBottom: true,
          position: Vector2(400.0 * i, randomVertical + (pipeGap / 2)),
        ),
      );
      await add(
        Pipe(
          isBottom: false,
          position: Vector2(400.0 * i, randomVertical - (pipeGap / 2)),
        ),
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.jump();
    if (!isStarted) {
      isStarted = true;
    }
  }
}
