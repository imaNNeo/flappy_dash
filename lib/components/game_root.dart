import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/components/guide_texts.dart';
import 'package:flappy_dash/cubit/game/game_cubit.dart';
import 'package:flappy_dash/flappy_dash_game.dart';

import 'dash.dart';
import 'parallax_background.dart';
import 'pipe_pair.dart';

class GameRoot extends Component
    with HasGameRef<FlappyDashGame>, HasCollisionDetection {
  GameRoot();

  late Dash player;

  static const pipeGap = 240.0;
  static const pipesHorizontalSpace = 400.0;

  StreamSubscription? _gameCubitSubscription;

  @override
  Future<void> onLoad() async {
    await initializeGame();
  }

  Future<void> initializeGame() async {
    await add(
      FlameBlocProvider<GameCubit, GameState>.value(
        value: game.gameCubit,
        children: [
          ParallaxBackground(),
          player = Dash(position: Vector2.zero()),
          GuideTexts(),
        ],
      ),
    );
  }

  @override
  void onRemove() {
    _gameCubitSubscription?.cancel();
    super.onRemove();
  }

  void gameOver() {
    removeAll(children);
    initializeGame();
  }

  void _startGame() async {
    await generateNextPipesBatch(
      count: 10,
      startFromX: (gameRef.size.x / 2) + 100,
    );
  }

  Future<void> generateNextPipesBatch({
    required int count,
    required double startFromX,
  }) async {
    final gameSize = gameRef.size;
    final pipesMinSize = gameSize.y * 0.25;
    final available = (gameSize.y - (pipesMinSize * 2));
    for (int i = 0; i < count; i++) {
      final randomVertical =
          (Random().nextDouble() * available) - (available / 2);
      await add(
        PipePair(
          gap: pipeGap,
          position: Vector2(
            startFromX + pipesHorizontalSpace * i,
            randomVertical,
          ),
        ),
      );
    }
  }

  int get pipesCount => children.whereType<PipePair>().length;

  PipePair get lastPipe => children.whereType<PipePair>().last;

  void tryToGenerateMorePipes() {
    final furtherPipes = children.whereType<PipePair>().where((pipe) {
      return pipe.position.x > player.position.x;
    });

    // Check if we have less than 5 pipes left, let's generate more
    if (furtherPipes.length < 5) {
      generateNextPipesBatch(
        count: 10,
        startFromX: lastPipe.position.x + pipesHorizontalSpace,
      );
    }

    // Remove beforePipes
    children
        .whereType<PipePair>()
        .where(
          (pipe) =>
              pipe.position.x + (pipesHorizontalSpace * 3) < player.position.x,
        )
        .forEach((pipe) => pipe.removeFromParent());
  }

  void onTapDown(TapDownEvent event) {
    player.jump();
    if (game.gameCubit.state.playingState.isNone) {
      game.gameCubit.startPlaying();
      _startGame();
    }
  }
}
