import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

import 'outline_text.dart';

class GameTitle extends StatelessWidget {
  const GameTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const OutlineText(
      Text(
        'Flappy Dash',
        style: TextStyle(
          fontSize: 98,
          fontWeight: FontWeight.bold,
          color: AppColors.blueColor,
          letterSpacing: 2,
        ),
      ),
      strokeWidth: 6,
      strokeColor: AppColors.darkBlueColor,
    );
  }
}
