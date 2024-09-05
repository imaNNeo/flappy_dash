import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/game_event.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/foundation.dart';
import 'package:nakama/nakama.dart';

import 'dash.dart';
import 'dash_parallax_background.dart';
import 'pipe_pair.dart';

class FlappyDashRootComponent extends Component
    with HasGameRef<FlappyDashGame>, FlameBlocListenable<GameCubit, GameState> {
  late Dash _dash;
  PipePair? _lastPipe;
  late DashParallaxBackground _background;
  late double pipesDistance;

  Map<String, Dash> currentOtherDashes = {};

  late int pipeCounter;

  late StreamSubscription _otherDashesEventSubscription;
  late StreamSubscription _matchPresenceStreamSubscription;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_background = DashParallaxBackground());
    add(_dash = Dash(
      position: Vector2.zero(),
      isMe: true,
      userId: 'me',
    ));
    game.camera.follow(_dash, horizontalOnly: true);
    mounted.then((_) {
      pipesDistance = bloc.state.gameConfig!.pipesDistance;
      _generatePipes(fromX: pipesDistance);
      _otherDashesEventSubscription =
          bloc.otherDashesEventStream.listen(_onOtherDashEventReceived);
      _syncOtherDashes(bloc.state.otherDashes);
    });
    pipeCounter = 0;
  }

  void _onOtherDashEventReceived((UserPresence, GameEvent) data) {
    final (presence, event) = data;
    if (presence.userId == bloc.state.currentUserId) {
      return;
    }
    switch (event) {
      case StartGameEventData():
        if (!currentOtherDashes.containsKey(presence.userId)) {
          return;
        }
        final doesExist = children.any((element) =>
            element is Dash && element.userId == presence.userId);
        if (!doesExist) {
          add(currentOtherDashes[presence.userId]!);
        }
        currentOtherDashes[presence.userId]!.position = Vector2(
          event.x,
          event.y,
        );
        currentOtherDashes[presence.userId]!.jump();
        break;
      case LetsTryAgainEventData():
        if (!currentOtherDashes.containsKey(presence.userId)) {
          return;
        }
        currentOtherDashes[presence.userId]!.position = Vector2(
          event.x,
          event.y,
        );
        break;
      case JumpEventData():
        if (!currentOtherDashes.containsKey(presence.userId)) {
          return;
        }
        currentOtherDashes[presence.userId]!.jump();
        break;
      case CorrectPositionEventData():
        if (!currentOtherDashes.containsKey(presence.userId)) {
          return;
        }
        currentOtherDashes[presence.userId]!.position = Vector2(
          event.x,
          event.y,
        );
        break;
      case UpdateScoreEventData():
        break;
      case LooseEventData():
        if (!currentOtherDashes.containsKey(presence.userId)) {
          return;
        }
        // Show loose animation, then remove
        currentOtherDashes[presence.userId]!.removeFromParent();
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

  @override
  bool listenWhen(GameState previousState, GameState newState) =>
      !mapEquals(previousState.otherDashes, newState.otherDashes);

  @override
  void onNewState(GameState state) {
    super.onNewState(state);
    _syncOtherDashes(state.otherDashes);
  }

  void _syncOtherDashes(
      UnmodifiableMapView<String, OtherDashState> newOtherDashes) {
    print('Syncing other dashes1');
    if (setEquals(
        currentOtherDashes.keys.toSet(), newOtherDashes.keys.toSet())) {
      return;
    }
    print('Syncing other dashes2');

    // remove old dashes
    for (final key in currentOtherDashes.keys.toList()) {
      if (!newOtherDashes.containsKey(key)) {
        currentOtherDashes[key]!.removeFromParent();
        currentOtherDashes.remove(key);
      }
    }

    // add new dashes
    for (final entry in newOtherDashes.entries) {
      if (!currentOtherDashes.containsKey(entry.key)) {
        Vector2? lastKnownPosition =
            bloc.state.otherDashesLastKnownPosition.containsKey(entry.key)
                ? bloc.state.otherDashesLastKnownPosition[entry.key]
                : null;
        final dash = Dash(
          position: lastKnownPosition ?? Vector2.zero(),
          isMe: false,
          userId: entry.key,
        );
        add(dash);
        currentOtherDashes[entry.key] = dash;
      }
    }

    // Remove me from the list
    final myId = bloc.state.currentUserId;
    currentOtherDashes.remove(myId);

    // Check if we synced correctly
    assert(
      setEquals(currentOtherDashes.keys.toSet(), newOtherDashes.keys.toSet()),
    );
  }

  // It works well, but there is an issue, when PlayerA and PlayerB looses,
  // PlayerA starts the game, then PlayerB starts the game after a short time,
  // PlayerB (which started later) sees PlayerA,
  // But PlayerA does not see PlayerB

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
      _generatePipes(fromX: _lastPipe!.x + pipesDistance);
      _removeLastPipes();
    }
  }

  @override
  void onRemove() {
    _otherDashesEventSubscription.cancel();
    _matchPresenceStreamSubscription.cancel();
    super.onRemove();
  }
}
