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

  void showToastSuccess(String message) {
    toastification.show(
      context: this,
      title: Text(message),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void showToastInfo(String message) {
    toastification.show(
      context: this,
      title: Text(message),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}