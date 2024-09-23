import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.child,
    this.onPressed,
    this.bgColor = AppColors.blueButtonBgColor50,
    this.strokeColor = AppColors.blueButtonStrokeColor,
    this.showLoading = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color strokeColor;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    return SizedBox(
      width: switch (screenSize) {
        ScreenSize.extraSmall => 280,
        ScreenSize.small => 300,
        ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 340,
      },
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          OutlinedButton(
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
          if (showLoading)
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(
                  PresentationConstants.defaultBorderRadius,
                ),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
        ],
      ),
    );
  }
}
