import 'package:flutter/material.dart';

import 'leaderboard_dialog.dart';

class AppDialogs {
  static Future<void> showLeaderboard(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const LeaderBoardDialog();
      },
    );
  }
}
