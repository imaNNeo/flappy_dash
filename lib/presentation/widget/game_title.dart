import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

import 'outline_text.dart';

class GameTitle extends StatelessWidget {
  const GameTitle({
    super.key,
    required this.screenSize,
  });

  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    return OutlineText(
      Text(
        'Flappy Dash',
        style: TextStyle(
          fontSize: switch(screenSize) {
            ScreenSize.extraSmall => 32,
            ScreenSize.small => 48,
            ScreenSize.medium => 76,
            ScreenSize.large || ScreenSize.extraLarge => 112,
          },
          fontWeight: FontWeight.bold,
          color: AppColors.blueColor,
          letterSpacing: 2,
        ),
      ),
      strokeWidth: switch(screenSize) {
        ScreenSize.extraSmall => 3,
        ScreenSize.small => 4,
        ScreenSize.medium => 6,
        ScreenSize.large || ScreenSize.extraLarge => 8,
      },
      strokeColor: AppColors.darkBlueColor,
    );
  }
}
