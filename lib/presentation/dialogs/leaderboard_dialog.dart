import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'raw_scores_list_dialog.dart';

class LeaderBoardDialog extends StatefulWidget {

  static Future<T?> show<T>(BuildContext context) =>
      showDialog<T?>(
        context: context,
        builder: (context) {
          return const LeaderBoardDialog();
        },
      );

  const LeaderBoardDialog({super.key});

  @override
  State<LeaderBoardDialog> createState() => _LeaderBoardDialogState();
}

class _LeaderBoardDialogState extends State<LeaderBoardDialog> {
  @override
  void initState() {
    context.read<LeaderboardCubit>().onLeaderboardPageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardCubit, LeaderboardState>(
      builder: (context, state) {
        final records = state.leaderboardEntity?.map((record, name) {
          return (
            name: name,
            isMe: record.ownerId == state.currentAccount?.user.id,
            dashType: DashType.fromUserId(record.ownerId ?? ''),
            score: int.parse(record.score ?? '0'),
            rank: int.parse(record.rank ?? '9999'),
          );
        });
        return RawScoresDialog(
          scores: records?.toList() ?? [],
        );
      },
    );
  }
}
