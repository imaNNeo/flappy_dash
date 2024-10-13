import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

class ErrorRetryBox extends StatelessWidget {
  const ErrorRetryBox({
    super.key,
    required this.error,
    required this.retry,
  });

  final String error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.dialogBgColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: retry,
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }
}
