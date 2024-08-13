import 'package:equatable/equatable.dart';

class OtherDashData with EquatableMixin {
  final String userId;
  final String userName;
  final double x;
  final double y;

  OtherDashData({
    required this.userId,
    required this.userName,
    required this.x,
    required this.y,
  });

  OtherDashData copyWith({
    String? userId,
    String? userName,
    double? x,
    double? y,
  }) =>
      OtherDashData(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        x: x ?? this.x,
        y: y ?? this.y,
      );

  @override
  List<Object?> get props => [userId, userName, x, y];
}
