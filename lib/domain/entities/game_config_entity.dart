import 'package:equatable/equatable.dart';

class GameConfigEntity with EquatableMixin {
  final List<double> pipesPosition;
  final double pipesPositionArea;
  final double pipesDistance;
  final double pipeWidth;
  final double pipeHoleSize;

  double get worldWidth => pipesDistance * (pipesPosition.length);

  const GameConfigEntity({
    required this.pipesPosition,
    required this.pipesPositionArea,
    required this.pipesDistance,
    required this.pipeWidth,
    required this.pipeHoleSize,
  });

  @override
  List<Object?> get props => [
        pipesPosition,
        pipesPositionArea,
        pipesDistance,
        pipeWidth,
        pipeHoleSize,
      ];
}
