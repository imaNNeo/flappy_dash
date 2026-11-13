import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Pipe extends PositionComponent {
  late Sprite _pipeSprite;

  final bool isFlipped;
  final double pipeWidth;

  Pipe({
    required this.isFlipped,
    required super.position,
    required this.pipeWidth,
  }) : super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pipeSprite = await Sprite.load('pipe.png');
    anchor = Anchor.topCenter;
    final ratio = _pipeSprite.srcSize.y / _pipeSprite.srcSize.x;
    size = Vector2(pipeWidth, pipeWidth * ratio);
    if (isFlipped) {
      flipVertically();
    }

    // Passive: pipes only need to be checked against the dash, never against
    // each other, which an active hitbox would make the broadphase do.
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _pipeSprite.render(canvas, size: size);
  }
}
