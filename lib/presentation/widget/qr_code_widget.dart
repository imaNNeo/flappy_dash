import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
    required this.qrCode,
    this.color = Colors.black,
  });

  final QrCode qrCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MyQrPainter(
        qrImage: QrImage(qrCode),
        color: color,
      ),
    );
  }
}

class _MyQrPainter extends CustomPainter {
  final QrImage qrImage;
  final Color color;
  final Paint _paint;

  _MyQrPainter({
    required this.qrImage,
    required this.color,
  }) : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / qrImage.moduleCount;
    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize,
              y * cellSize,
              cellSize + 1,
              cellSize + 1,
            ),
            _paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MyQrPainter oldDelegate) =>
      oldDelegate.qrImage != qrImage || oldDelegate.color != color;
}
