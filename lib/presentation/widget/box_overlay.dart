import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

class BoxOverlay extends StatelessWidget {
  const BoxOverlay({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 18.0,
      vertical: 12.0,
    ),
    this.borderRadius = PresentationConstants.defaultBorderRadiusSmall,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.boxBgColor,
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
