import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';

import 'dash.dart';
import 'dash_parallax_background.dart';
import 'pipe_pair.dart';

class FlappyDashRootComponent extends Component
    with HasGameRef<FlappyDashGame>, FlameBlocReader<GameCubit, GameState> {
  late Dash _dash;
  late PipePair _lastPipe;
  late DashParallaxBackground _background;
  late final GameConfigEntity _config;

  int _pipeCounter = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_background = DashParallaxBackground());
    add(_dash = Dash());
    _config = bloc.state.gameMode!.gameConfig;
    _generatePipes(
      fromX: _config.pipesDistance,
    );
    game.camera.follow(_dash, horizontalOnly: true);
  }

  double _getNewPipeYForMultiplayer(MultiplayerGameConfigEntity config) {
    final pipesPosition =
        (_config as MultiplayerGameConfigEntity).pipesPosition;
    final posIndex = _pipeCounter % pipesPosition.length;
    return pipesPosition[posIndex] * _config.pipesPositionArea;
  }

  void _generatePipes({
    int count = 1,
    required double fromX,
  }) {
    for (int i = 0; i < count; i++) {
      final area = _config.pipesPositionArea;

      final y = switch (_config) {
        SinglePlayerGameConfigEntity() =>
          (Random().nextDouble() * area) - (area / 2),
        MultiplayerGameConfigEntity() => _getNewPipeYForMultiplayer(_config),
      };

      add(_lastPipe = PipePair(
        position: Vector2(fromX + (i * _config.pipesDistance), y),
        gap: _config.pipeHoleGap,
        pipeWidth: _config.pipeWidth,
      ));
      _pipeCounter++;
    }
  }

  void _removeLastPipes() {
    final pipes = children.whereType<PipePair>();
    final shouldBeRemoved = max(pipes.length - 5, 0);
    pipes.take(shouldBeRemoved).forEach((pipe) {
      pipe.removeFromParent();
    });
  }

  void onSpaceDown() {
    _checkToStart();
    _dash.jump();
  }

  void onTapDown(TapDownEvent event) {
    _checkToStart();
    _dash.jump();
  }

  void _checkToStart() {
    if (bloc.state.currentPlayingState.isIdle) {
      bloc.startPlaying();
    }
  }

  PipePair _removeAllPipesExceptLastOne() {
    final pipes = children.whereType<PipePair>();
    for (int i = pipes.length - 2; i >= 0; i--) {
      pipes.elementAt(i).removeFromParent();
    }
    return pipes.last;
  }

  void _tryToLoopTheGame() {
    if (_config is! MultiplayerGameConfigEntity) {
      return;
    }

    // We loop if the dash is out of the screen
    if (_dash.x < _config.worldWidth) {
      return;
    }

    final lastPipe = _removeAllPipesExceptLastOne();
    lastPipe.x = 0.0;
    _dash.x = 0.0;
    _background.x = 0.0;
    _pipeCounter = 0;
    _generatePipes(
      fromX: _config.pipesDistance,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _background.x = _dash.x;
    _tryToLoopTheGame();
    if (_dash.x >= _lastPipe.x) {
      _generatePipes(
        fromX: _lastPipe.x + _config.pipesDistance,
      );
      _removeLastPipes();
    }
    game.camera.viewfinder.zoom = 1.0;
  }
}
