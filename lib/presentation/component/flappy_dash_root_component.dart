import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/other_dash_entity.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'dash.dart';
import 'dash_parallax_background.dart';
import 'other_dash.dart';
import 'pipe_pair.dart';

class FlappyDashRootComponent extends Component
    with HasGameRef<FlappyDashGame>, FlameBlocListenable<GameCubit, GameState> {
  late Dash _dash;
  PipePair? _lastPipe;
  late DashParallaxBackground _background;
  late double pipesDistance;

  Map<String, OtherDash> currentOtherDashes = {};

  late int pipeCounter;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_background = DashParallaxBackground());
    add(_dash = Dash());
    game.camera.follow(_dash, horizontalOnly: true);
    mounted.then((_) {
      pipesDistance = bloc.state.gameConfig!.pipesDistance;
      _generatePipes(fromX: pipesDistance);
    });
    pipeCounter = 0;
  }

  @override
  void onNewState(GameState state) {
    super.onNewState(state);
    final updatedDashes = state.otherDashes.keys.toSet();
    final showingDashes = currentOtherDashes.keys.toSet();
    final hasDiff = updatedDashes.difference(showingDashes).isNotEmpty;
    if (hasDiff) {
      syncDashes(state.otherDashes);
    }
  }

  void syncDashes(Map<String, OtherDashData> otherDashes) {
    final tempCurrentKeys = currentOtherDashes.keys.toSet();

    // Let's create or update the current dashes
    for (final userId in otherDashes.keys) {
      final otherDashData = otherDashes[userId]!;
      tempCurrentKeys.remove(userId);
      if (!currentOtherDashes.containsKey(userId)) {
        final otherDash = OtherDash(data: otherDashData);
        currentOtherDashes[userId] = otherDash;
        add(otherDash);
      }
    }

    // Let's remove the dashes that doesn't exist in the list
    if (tempCurrentKeys.isNotEmpty) {
      for (final userId in tempCurrentKeys) {
        currentOtherDashes[userId]!.removeFromParent();
        currentOtherDashes.remove(userId);
      }
    }
  }

  void _generatePipes({
    int count = 1,
    required double fromX,
  }) {
    final config = bloc.state.gameConfig!;
    for (int i = 0; i < count; i++) {
      final area = config.pipesPositionArea;
      final posIndex = pipeCounter % config.pipesPosition.length;
      final y = config.pipesPosition[posIndex] * area;
      add(_lastPipe = PipePair(
        position: Vector2(fromX + (i * pipesDistance), y),
        gap: config.pipeHoleSize,
        pipeWidth: config.pipeWidth,
      ));
      pipeCounter++;
    }
  }

  void _removeLastPipes() {
    final pipes = children.whereType<PipePair>();
    final shouldBeRemoved = max(pipes.length - 1, 0);
    pipes.take(shouldBeRemoved).forEach((pipe) {
      pipe.removeFromParent();
    });
  }

  PipePair _removeAllPipesExceptLastOne() {
    final pipes = children.whereType<PipePair>();
    for (int i = pipes.length - 2; i >= 0; i--) {
      pipes.elementAt(i).removeFromParent();
    }
    return pipes.last;
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

  void _loopPositions() {
    final lastPipe = _removeAllPipesExceptLastOne();
    lastPipe.x = 0.0;
    _dash.x = 0.0;
    _background.x = 0.0;
    _generatePipes(
      fromX: pipesDistance,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _background.x = _dash.x;
    if (_dash.x > bloc.state.gameConfig!.worldWidth) {
      _loopPositions();
      return;
    }
    if (_lastPipe != null && _dash.x >= _lastPipe!.x) {
      _generatePipes(
        fromX: _lastPipe!.x + pipesDistance,
      );
      _removeLastPipes();
    }
  }
}
