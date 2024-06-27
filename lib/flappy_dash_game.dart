import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'components/game_root.dart';
import 'cubit/game/game_cubit.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld> {
  FlappyDashGame(this.gameCubit)
      : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 800,
            height: 1000,
          ),
        );

  final GameCubit gameCubit;
}

class FlappyDashWorld extends World
    with HasGameRef<FlappyDashGame>, TapCallbacks, HasCollisionDetection {
  late GameRoot _gameRoot;

  @override
  Future<void> onLoad() async {
    await add(
      FlameBlocProvider<GameCubit, GameState>(
        create: () => game.gameCubit,
        children: [
          _gameRoot = GameRoot(),
        ],
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _gameRoot.onTapDown(event);
  }
}
