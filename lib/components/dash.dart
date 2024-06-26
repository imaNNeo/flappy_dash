import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flappy_dash/flappy_dash_game.dart';

class Dash extends PositionComponent with HasGameRef<FlappyDashGame> {
  Dash({
    required super.position,
  }) : super(
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  static const double gravity = 1600;
  static const double jumpForce = -500;
  static const double ground = 500.0;

  double velocity = 0;

  late Sprite _dashSprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _dashSprite = await Sprite.load('dash.png');
    velocity = 0;
    position.y = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.world.isStarted) {
      return;
    }
    velocity += gravity * dt;
    position.y += velocity * dt;


    if (position.y > ground) {
      position.y = ground;
      velocity = 0;
    }
    if (position.y < -ground) {
      position.y = -ground;
      velocity = 0;
    }
  }

  void jump() {
    velocity = jumpForce;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSprite.render(
      canvas,
      size: size,
    );
  }
}
