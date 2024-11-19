import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/component/pipe_pair.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'dash.dart';

class AutoJumpDash extends Component with ParentIsA<Dash> {
  PipePair? _nextPipe;

  PlayingState get currentPlayingState => parent.currentPlayingState;

  Vector2 get position => parent.position;

  double get myLeft => position.x - parent.size.x / 2;

  FlappyDashGame get gameRef => parent.gameRef;

  double get velocityY => parent.velocityY;

  double get gravity => parent.gravity;

  double get jumpForce => parent.jumpForce;

  bool randomFail = false;
  bool failByExtraJump = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (currentPlayingState.isNotPlaying) {
      return;
    }

    _makeJumpDecision(_getNextPipe(), dt);
  }

  PipePair? _getNextPipe() {
    if (_nextPipe != null &&
        myLeft < _nextPipe!.position.x + _nextPipe!.pipeWidth) {
      return _nextPipe!;
    }

    final pipes =
        gameRef.world.rootComponent.children.whereType<PipePair>().toList();
    if (pipes.isEmpty) {
      return null;
    }

    pipes.sort((a, b) => a.position.x.compareTo(b.position.x));

    for (final pipe in pipes) {
      final pipeRight = pipe.position.x + pipe.pipeWidth;

      if (myLeft < pipeRight) {
        randomFail = gameRef.random.nextDouble() < 0.2;
        failByExtraJump = gameRef.random.nextBool();
        _nextPipe = pipe;
        return _nextPipe!;
      }
    }

    return null;
  }

  double getBottomLineEdge(PipePair nextPipe) {
    // Calculate the target and predicted positions
    final bottomPipeEdge = nextPipe.position.y + nextPipe.gap / 2;
    return bottomPipeEdge - nextPipe.gap * 0.25;
  }

  void _makeJumpDecision(PipePair? nextPipe, double dt) {
    if (nextPipe == null) {
      return;
    }

    final nearToPipe = (position.x - nextPipe.position.x).abs() < 100;
    print('randomFail: $randomFail, failByExtraJump: $failByExtraJump, nearToPipe: $nearToPipe');
    if (nearToPipe && randomFail) {
      if (failByExtraJump) {
        parent.jump();
      } else {
        return;
      }
    }

    if (position.y > getBottomLineEdge(nextPipe) && velocityY > 10) {
      parent.jump();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (debugMode) {
      // Draw a line to the next pipe
      final nextPipe = _getNextPipe();
      if (nextPipe != null) {
        final targetX = nextPipe.position.x + nextPipe.pipeWidth / 2;
        final targetY = getBottomLineEdge(nextPipe);
        canvas.drawLine(
          (parent.size / 2).toOffset(),
          Offset(
            targetX - position.x,
            targetY - position.y,
          ),
          Paint()
            ..color = const Color(0xFFFF0000)
            ..strokeWidth = 2,
        );
      }
    }
  }
}
