import 'dart:ui';

import 'package:flame/components.dart';

class Dash extends PositionComponent {
  Dash({
    required super.position,
  }) : super(
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  late Sprite _dashSprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _dashSprite = await Sprite.load('dash.png');
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
