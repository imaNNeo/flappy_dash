import 'package:flame/components.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'hidden_coin.dart';

class PipePair extends PositionComponent with HasGameRef<FlappyDashGame> {
  PipePair({
    required super.position,
    required this.gap,
    required this.pipeWidth,
    super.priority,
  });

  final double gap;
  final double pipeWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll([
      Pipe(
        isFlipped: false,
        position: Vector2(0, gap / 2),
        pipeWidth: pipeWidth,
      ),
      Pipe(
        isFlipped: true,
        position: Vector2(0, -(gap / 2)),
        pipeWidth: pipeWidth,
      ),
      HiddenCoin(
        position: Vector2(30, 0),
        size: Vector2(40, game.gameMode.gameConfig.pipeHoleGap * 0.9),
      ),
    ]);
  }
}
