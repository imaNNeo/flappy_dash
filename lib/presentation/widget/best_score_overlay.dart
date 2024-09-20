import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/dialogs/leaderboard_dialog.dart';
import 'package:flutter/material.dart';

import 'box_overlay.dart';

class BestScoreOverlay extends StatelessWidget {
  const BestScoreOverlay({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BoxOverlay(
      onTap: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreTrophy(size: 32, rank: 1),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your best',
                style: TextStyle(
                  color: AppColors.whiteTextColor,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                '122',
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
