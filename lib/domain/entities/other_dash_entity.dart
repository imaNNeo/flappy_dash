import 'package:equatable/equatable.dart';

class OtherDashData with EquatableMixin {
  final double x;
  final double y;

  OtherDashData({
    required this.x,
    required this.y,
  });

  @override
  List<Object?> get props => [x, y];
}
