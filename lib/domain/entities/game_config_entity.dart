import 'package:equatable/equatable.dart';

sealed class GameConfigEntity with EquatableMixin {
  const GameConfigEntity();
}

class SinglePlayerGameConfigEntity extends GameConfigEntity {
  const SinglePlayerGameConfigEntity({
    this.gravityY = 1400.0,
    this.pipesPositionArea = 300.0,
    this.pipesDistance = 420.0,
    this.pipeWidth = 82.0,
    this.pipeHoleGap = 240,
    this.dashMoveSpeed = 160.0,
    this.jumpForce = -500.0,
  });

  final double gravityY;

  final double pipesPositionArea;

  final double pipesDistance;

  final double pipeWidth;

  final double pipeHoleGap;

  final double dashMoveSpeed;

  final double jumpForce;

  @override
  List<Object?> get props => [
        pipesPositionArea,
        pipesDistance,
        pipeWidth,
        pipeHoleGap,
        dashMoveSpeed,
        jumpForce,
      ];
}

class MultiplayerGameConfigEntity extends GameConfigEntity {
  const MultiplayerGameConfigEntity();

  @override
  List<Object?> get props => [];
}
