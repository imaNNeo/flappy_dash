import 'package:flappy_dash/presentation/helpers/update_helper/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AppUpdateHelper {
  static Future<void> handleUpdateRequired(BuildContext context) async {
    final result = await UpdateDialog.show(context, actionButton: 'Reload');
    if (result == true) {
      web.window.location.reload();
    }
  }
}
