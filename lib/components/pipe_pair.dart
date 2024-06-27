import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/cubit/game/game_cubit.dart';

import 'pipe.dart';

class PipePair extends PositionComponent
    with FlameBlocReader<GameCubit, GameState> {
  PipePair({
    required super.position,
    required this.gap,
  }) : super();

  final double gap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll([
      Pipe(
        isBottom: true,
        position: Vector2(
          0,
          gap / 2,
        ),
      ),
      Pipe(
        isBottom: false,
        position: Vector2(
          0,
          -(gap / 2),
        ),
      ),
      HiddenCoin(position: Vector2(40, 0)),
    ]);
  }

  @override
  void update(double dt) {
    if (!bloc.state.playingState.isPlaying) {
      return;
    }
    position.x -= 200 * dt;
    super.update(dt);
  }
}

class HiddenCoin extends PositionComponent {
  HiddenCoin({
    required super.position,
  }) : super(
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(
      collisionType: CollisionType.passive,
    ));
  }
}
