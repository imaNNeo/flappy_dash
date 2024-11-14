import 'package:flappy_dash/presentation/helpers/update_helper/update_dialog.dart';
import 'package:flutter/material.dart';

class AppUpdateHelper {
  static Future<void> handleUpdateRequired(BuildContext context) async {
    final result = await UpdateDialog.show(context);
    if (result == true) {
      // open the app store
    }
  }
}
