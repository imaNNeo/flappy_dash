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
  GameRoot? _gameRoot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeGame();
    game.gameCubit.restartNotifier.addListener(_restartGame);
  }

  void _restartGame() async {
    if (game.gameCubit.restartNotifier.value) {
      removeAll(children);
      await _initializeGame();
    }
  }

  Future<void> _initializeGame() async {
    await add(
      FlameBlocProvider<GameCubit, GameState>.value(
        value: game.gameCubit,
        children: [
          _gameRoot = GameRoot(),
        ],
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _gameRoot!.onTapDown(event);
  }

  @override
  void onRemove() {
    game.gameCubit.restartNotifier.removeListener(_restartGame);
    super.onRemove();
  }
}
