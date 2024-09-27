import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
extension BuildContextExtension on BuildContext {
  void showToastError(String error) {
    toastification.show(
      context: this,
      title: Text(error),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}