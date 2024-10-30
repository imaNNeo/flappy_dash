import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashImage extends StatelessWidget {
  const DashImage({
    super.key,
    required this.size,
    required this.type,
  });

  final double size;
  final DashType type;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      type.assetName,
      width: size,
      height: size,
    );
  }
}
