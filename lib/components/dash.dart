import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/components/game_root.dart';
import 'package:flappy_dash/components/pipe.dart';
import 'package:flappy_dash/cubit/game/game_cubit.dart';
import 'package:flappy_dash/flappy_dash_game.dart';

import 'pipe_pair.dart';

class Dash extends PositionComponent
    with
        HasGameRef<FlappyDashGame>,
        CollisionCallbacks,
        FlameBlocReader<GameCubit, GameState>,
        HasAncestor<GameRoot> {
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
    final displacement = size * 0.04;
    add(CircleHitbox(
      radius: (size.x / 2) * 0.8,
      anchor: Anchor.center,
      position: (size / 2) + displacement,
      collisionType: CollisionType.active,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (bloc.state.playingState != PlayingState.playing) {
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Pipe) {
      bloc.gameOver();
    } else if (other is HiddenCoin) {
      bloc.onScoreCollected();
      other.removeFromParent();
      ancestor.tryToGenerateMorePipes();
    }
  }
}
