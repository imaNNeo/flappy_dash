import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld> {
  FlappyDashGame()
      : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 600,
            height: 1000,
          ),
        );
}

class FlappyDashWorld extends World {
  @override
  void onLoad() {
    super.onLoad();
    add(Dash());
    add(RectangleComponent(
      position: Vector2(10.0, 15.0),
      size: Vector2.all(10),
      angle: pi / 2,
      anchor: Anchor.center,
    ));
  }
}

class Dash extends PositionComponent {
  Dash()
      : super(
          position: Vector2(0, 0),
          size: Vector2(40, 40),
        );

  @override
  void update(double dt) {
    super.update(dt);
    position = Vector2.zero();
    angle += 0.01;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      BasicPalette.red.paint(),
    );
  }
}
