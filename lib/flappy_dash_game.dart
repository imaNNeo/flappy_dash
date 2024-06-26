import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flappy_dash/components/dash.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld> {
  FlappyDashGame()
      : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 800,
            height: 1200,
          ),
        );
}

class FlappyDashWorld extends World with HasGameRef<FlappyDashGame> {
  late Dash player;

  @override
  Future<void> onLoad() async {
    await add(player = Dash(position: Vector2.zero()));
  }
}
