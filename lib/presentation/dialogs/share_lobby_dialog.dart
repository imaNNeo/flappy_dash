import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/presentation/widget/qr_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr/qr.dart';

class ShareQRContentDialog extends StatefulWidget {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String data,
  }) {
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return ShareQRContentDialog(
          title: title,
          data: data,
        );
      },
    );
  }

  const ShareQRContentDialog({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;
  final String data;

  @override
  State<ShareQRContentDialog> createState() => _ShareQRContentDialogState();
}

class _ShareQRContentDialogState extends State<ShareQRContentDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.0,
                  child: QrCodeWidget(
                    qrCode: QrCode(5, QrErrorCorrectLevel.M)
                      ..addData(widget.data),
                    color: AppColors.dialogBgColor,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.data));
                        context.showToastInfo('Copied to clipboard');
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
