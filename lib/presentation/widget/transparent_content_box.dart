import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

class TransparentContentBox extends StatelessWidget {
  const TransparentContentBox({
    super.key,
    required this.child,
    this.width = 680,
    this.margin = const EdgeInsets.symmetric(horizontal: 48),
  });

  final Widget child;
  final double width;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    const borderSize = BorderSide(
      color: Colors.black,
      width: 4,
    );
    return Container(
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor60,
        borderRadius: BorderRadius.circular(
          PresentationConstants.defaultBorderRadius,
        ),
        border: Border(
          top: borderSize,
          left: borderSize,
          bottom: borderSize.copyWith(
            width: borderSize.width * 2,
          ),
          right: borderSize,
        ),
      ),
      child: child,
    );
  }
}