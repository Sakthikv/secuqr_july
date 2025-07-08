import 'package:flutter/material.dart';

class CornerBorderPainter extends CustomPainter {
  final double squareSize;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius; // Corner radius for rounded edges
  final double offset; // Additional offset for spacing between border and square

  CornerBorderPainter({
    required this.squareSize,
    required this.borderWidth,
    required this.borderColor,
    required this.borderRadius, // Initialize corner radius
    this.offset = 10.0, // Default offset to move the border away
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Adjust position by adding offset
    final double left = (size.width - squareSize) / 2 - offset;
    final double top = (size.height - squareSize) / 2 - 100 - offset;
    final double adjustedSquareSize = squareSize + (2 * offset);

    // Draw a rounded rectangle border
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, adjustedSquareSize, adjustedSquareSize),
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}