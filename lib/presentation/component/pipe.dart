import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Pipe extends PositionComponent {
  late Sprite _pipeSprite;

  final bool isFlipped;

  Pipe({
    required this.isFlipped,
    required super.position,
  }): super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pipeSprite = await Sprite.load('pipe.png');
    anchor = Anchor.topCenter;
    final ratio = _pipeSprite.srcSize.y / _pipeSprite.srcSize.x;
    const width = 82.0;
    size = Vector2(width, width * ratio);
    if (isFlipped) {
      flipVertically();
    }

    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _pipeSprite.render(
      canvas,
      position: Vector2.zero(),
      size: size,
    );
  }
}
