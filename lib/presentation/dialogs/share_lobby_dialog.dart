import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/presentation/widget/game_dialog.dart';
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
        return ShareQRContentDialog(title: title, data: data);
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
    final size = MediaQuery.sizeOf(context);
    // The QR code must stay square and fully visible, also on a phone in
    // landscape where there is little height.
    final qrSize = (size.height - 220).clamp(140.0, 300.0);
    return GameDialog(
      title: widget.title,
      maxWidth: 420,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: qrSize,
              height: qrSize,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrCodeWidget(
                qrCode: QrCode(
                  payload: QrPayload.fromString(widget.data),
                  errorCorrectLevel: QrErrorCorrectLevel.medium,
                  minTypeNumber: 5,
                ),
                color: AppColors.dialogBgColor,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.data,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.whiteTextColor,
                        fontSize: 12,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy link',
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.data));
                      context.showToastInfo('Copied to clipboard');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
