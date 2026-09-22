import 'package:flutter/material.dart';

class DottedBottomBorderPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DottedBottomBorderPainter({
    required this.color,
    this.dashWidth = 5.0, // Default dash width
    required this.dashSpace, // Required dash space
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color // Use the passed color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double startX = 0;

    // Draw only the bottom border
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace; // Use the passed dashSpace
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}