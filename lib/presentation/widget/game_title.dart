import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

import 'gradient_text.dart';
import 'outline_text.dart';

class GameTitle extends StatelessWidget {
  const GameTitle({
    super.key,
    required this.screenSize,
    this.showMultiplayerText = false,
  });

  final ScreenSize screenSize;
  final bool showMultiplayerText;

  @override
  Widget build(BuildContext context) {
    final fontSize = switch (screenSize) {
      ScreenSize.extraSmall => 58.0,
      ScreenSize.small => 66.0,
      ScreenSize.medium => 76.0,
      ScreenSize.large || ScreenSize.extraLarge => 112.0,
    };
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        OutlineText(
          Text(
            'Flappy Dash',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
              letterSpacing: 2,
            ),
          ),
          strokeWidth: switch (screenSize) {
            ScreenSize.extraSmall => 3,
            ScreenSize.small => 4,
            ScreenSize.medium => 6,
            ScreenSize.large || ScreenSize.extraLarge => 8,
          },
          strokeColor: AppColors.darkBlueColor,
        ),
        if (showMultiplayerText)
          Transform.translate(
            offset: Offset(fontSize * 0.15, fontSize * 0.4),
            child: GradientText(
              'Multi Player',
              gradient: const LinearGradient(
                colors: AppColors.multiColorGradient,
              ),
              style: TextStyle(
                fontSize: fontSize * 0.41,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
