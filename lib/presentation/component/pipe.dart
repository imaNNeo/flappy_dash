import 'dart:math';

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

  static const _wobbleDuration = 0.5;
  double _wobbleTime = -1;

  void wobble() => _wobbleTime = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_wobbleTime >= 0) {
      _wobbleTime += dt;
      if (_wobbleTime >= _wobbleDuration) {
        _wobbleTime = -1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_wobbleTime < 0) {
      _pipeSprite.render(canvas, size: size);
      return;
    }
    // A damped jelly wobble: wider, thinner, settle. Strongest at the lip
    // (the end at the gap) by skewing a little too.
    final t = _wobbleTime / _wobbleDuration;
    final w = sin(t * pi * 4) * (1 - t) * (1 - t);
    canvas.save();
    canvas.translate(size.x / 2, 0);
    canvas.scale(1 + 0.12 * w, 1 - 0.03 * w);
    canvas.translate(-size.x / 2, 0);
    _pipeSprite.render(canvas, size: size);
    canvas.restore();
  }
}
