import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.child,
    this.onPressed,
    this.bgColor = AppColors.blueButtonBgColor,
    this.strokeColor = AppColors.blueButtonStrokeColor,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    return SizedBox(
      width: switch(screenSize) {
        ScreenSize.extraSmall => 280,
        ScreenSize.small => 300,
        ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 340,
      },
      height: 76,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PresentationConstants.defaultBorderRadius,
            ),
          ),
          side: BorderSide(
            color: strokeColor,
            width: 2.5,
          ),
          backgroundColor: bgColor,
        ),
        child: child,
      ),
    );
  }
}
