import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/leaderboard_dialog.dart';
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
    return BlocBuilder<GameCubit, GameState>(builder: (context, state) {
      final record = state.leaderboardEntity?.ownerRecord;
      return BoxOverlay(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScoreTrophy(size: 32, rank: record?.rank),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your best',
                  style: TextStyle(
                    color: AppColors.whiteTextColor,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  record?.score.toString() ?? '-',
                  style: const TextStyle(
                    color: AppColors.mainColor,
                    fontSize: 22,
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
