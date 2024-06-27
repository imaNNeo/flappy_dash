import 'package:flame/components.dart';

import 'pipe.dart';

class PipePair extends PositionComponent {
  PipePair({
    required super.position,
    required this.gap,
  });

  final double gap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      Pipe(
        isBottom: true,
        position: Vector2(
          0,
          gap / 2,
        ),
      ),
    );
    await add(
      Pipe(
        isBottom: false,
        position: Vector2(
          0,
          -(gap / 2),
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    position.x -= 200 * dt;
    super.update(dt);
  }

}
