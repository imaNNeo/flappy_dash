import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class HiddenCoin extends PositionComponent {
  HiddenCoin({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  @override
  void onLoad() {
    super.onLoad();
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
  }
}
