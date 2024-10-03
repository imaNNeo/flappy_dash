import 'package:equatable/equatable.dart';

sealed class GameConfigEntity with EquatableMixin {
  const GameConfigEntity();

  abstract final double pipesPositionArea;
  abstract final double pipesDistance;
  abstract final double pipeWidth;
  abstract final double pipeHoleGap;
}

class SinglePlayerGameConfigEntity extends GameConfigEntity {
  const SinglePlayerGameConfigEntity({
    this.pipesPositionArea = 300.0,
    this.pipesDistance = 400.0,
    this.pipeWidth = 82.0,
    this.pipeHoleGap = 200,
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
    this.pipesDistance = 400.0,
    this.pipeWidth = 82.0,
    this.pipeHoleGap = 200,
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
