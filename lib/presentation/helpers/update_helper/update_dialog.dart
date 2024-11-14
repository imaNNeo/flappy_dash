import 'package:flutter/material.dart';

class UpdateDialog {
  static Future<bool?> show(
    BuildContext context, {
    String actionButton = 'Update',
  }) {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Outdated Version',
          ),
          content: const Text(
            'Please update the app to the latest version to continue using it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionButton),
            ),
          ],
        );
      },
    );
  }
}
