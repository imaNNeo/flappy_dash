import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

class BoxOverlay extends StatelessWidget {
  const BoxOverlay({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.boxBgColor,
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 12.0,
          ),
          child: child,
        ),
      ),
    );
  }
}
