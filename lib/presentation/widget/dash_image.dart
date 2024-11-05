import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flutter/material.dart';

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
    return Image.asset(
      type.pngAssetName,
      width: size,
      height: size,
    );
  }
}
