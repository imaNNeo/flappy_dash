import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/raw_scores_list_dialog.dart';
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

    return BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
      final record = state.leaderboardEntity?.ownerRecord;
      int? rank = int.tryParse(record?.rank ?? '');
      int score = int.tryParse(record?.score ?? '') ?? 0;
      return BoxOverlay(
        padding: EdgeInsets.symmetric(
          horizontal: relative(14.0),
          vertical: relative(6.0),
        ),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (rank) {
              null || <= 3 => ScoreTrophy(size: 32, rank: rank),
              _ => NormalScore(
                  size: 38,
                  rank: rank,
                ),
            },
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
                  score.toString(),
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
