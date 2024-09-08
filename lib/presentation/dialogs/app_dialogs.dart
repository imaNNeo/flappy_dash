import 'package:flutter/material.dart';

import 'leaderboard_dialog.dart';
import 'nickname_dialog.dart';

class AppDialogs {
  static Future<void> showLeaderboard(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const LeaderBoardDialog();
      },
    );
  }

  static Future<void> nicknameDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const NicknameDialog();
      },
    );
  }
}
