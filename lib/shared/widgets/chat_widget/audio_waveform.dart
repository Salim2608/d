import 'package:flutter/material.dart';

class AudioWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Create a wave pattern
    final barWidth = 3.0;
    final space = 3.0;
    final waveCount = size.width ~/ (barWidth + space);

    for (int i = 0; i < waveCount; i++) {
      // Create varying heights for the bars
      final isEven = i % 2 == 0;
      final normalizedHeight =
          isEven ? (i % 7) / 7 * 0.9 + 0.1 : ((7 - i % 7) / 7) * 0.9 + 0.1;

      final barHeight = size.height * normalizedHeight;
      final startX = i * (barWidth + space);

      final startPoint = Offset(startX, (size.height - barHeight) / 2);
      final endPoint = Offset(startX, startPoint.dy + barHeight);

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
