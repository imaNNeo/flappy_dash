import 'dart:ui';

import 'package:flame/components.dart';

class Pipe extends PositionComponent {
  Pipe({
    required this.isBottom,
    required super.position,
  }) : super(
          size: Vector2(100, 100),
          anchor: Anchor.center,
        );

  late Sprite _pipeSprite;

  final bool isBottom;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pipeSprite = await Sprite.load('pipe.png');
    final ratio = _pipeSprite.srcSize.x / _pipeSprite.srcSize.y;
    size = Vector2(100, 100 / ratio);
    anchor = Anchor.topCenter;
    if (!isBottom) {
      flipVertically();
    }
  }

  @override
  void update(double dt) {
    position.x -= 200 * dt;
    super.update(dt);
  }


  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _pipeSprite.render(
      canvas,
      size: size,
    );
  }
}
