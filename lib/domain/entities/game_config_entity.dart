import 'package:equatable/equatable.dart';

sealed class GameConfigEntity with EquatableMixin {
  const GameConfigEntity();

  final double dashMoveSpeed = 160.0;
  abstract final double pipesPositionArea;
  abstract final double pipesDistance;
  abstract final double pipeWidth;
  abstract final double pipeHoleGap;
}

class SinglePlayerGameConfigEntity extends GameConfigEntity {
  const SinglePlayerGameConfigEntity({
    this.pipesPositionArea = 300.0,
    this.pipesDistance = 420.0,
    this.pipeWidth = 82.0,
    this.pipeHoleGap = 240,
  });

  @override
  final double pipesPositionArea;

  @override
  final double pipesDistance;

  @override
  final double pipeWidth;

  @override
  final double pipeHoleGap;

  @override
  List<Object?> get props => [
        pipesPositionArea,
        pipesDistance,
        pipeWidth,
        pipeHoleGap,
      ];
}

class MultiplayerGameConfigEntity extends GameConfigEntity {
  const MultiplayerGameConfigEntity({
    this.pipesPositionArea = 300.0,
    this.pipesDistance = 420.0,
    this.pipeWidth = 82.0,
    this.pipeHoleGap = 200,
    this.spawnAgainAfterSeconds = 5,
    this.correctPositionEvery = 5.0,
  });

  @override
  final double pipesPositionArea;

  @override
  final double pipesDistance;

  @override
  final double pipeWidth;

  @override
  final double pipeHoleGap;

  final int spawnAgainAfterSeconds;

  final double correctPositionEvery;

  @override
  List<Object?> get props => [
        pipesPositionArea,
        pipesDistance,
        pipeWidth,
        pipeHoleGap,
        spawnAgainAfterSeconds,
        correctPositionEvery,
      ];
}
