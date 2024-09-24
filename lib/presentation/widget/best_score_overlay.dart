import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/leaderboard_dialog.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'box_overlay.dart';

class BestScoreOverlay extends StatelessWidget {
  const BestScoreOverlay({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final multiplier = switch (screenSize) {
      ScreenSize.extraSmall => 0.6,
      ScreenSize.small => 0.7,
      ScreenSize.medium => 1.0,
      ScreenSize.large => 1.1,
      ScreenSize.extraLarge => 1.2,
    };
    double relative(double value) => value * multiplier;

    return BlocBuilder<GameCubit, GameState>(builder: (context, state) {
      final record = state.leaderboardEntity?.ownerRecord;
      return BoxOverlay(
        padding: EdgeInsets.symmetric(
          horizontal: relative(14.0),
          vertical: relative(6.0),
        ),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScoreTrophy(
              size: relative(36),
              rank: record?.rank,
            ),
            SizedBox(width: relative(18)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your best',
                  style: TextStyle(
                    color: AppColors.whiteTextColor,
                    fontSize: relative(16),
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  record?.score.toString() ?? '-',
                  style: TextStyle(
                    color: AppColors.mainColor,
                    fontSize: relative(26),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
