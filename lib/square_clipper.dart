import 'package:flutter/material.dart';

class RoundedSquareClipper extends CustomClipper<Path> {
  final double squareSize;
  final double borderRadius;
  final double verticalOffset; // New parameter for vertical offset

  RoundedSquareClipper({
    required this.squareSize,
    required this.borderRadius,
    this.verticalOffset = 0, // Default value is 0 (no offset)
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    // Fill the entire path with transparency
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // Cut out the clear rounded square area in the center
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - squareSize) / 2,
          (size.height - squareSize) / 2 - verticalOffset, // Subtract vertical offset here
          squareSize,
          squareSize,
        ),
        Radius.circular(borderRadius),
      ),
    );
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
// Custom Painter to Draw Blue Border Around the Square
class SquareBorderPainter extends CustomPainter {
  final double squareSize;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final double verticalOffset;

  SquareBorderPainter({
    required this.squareSize,
    required this.borderWidth,
    required this.borderColor,
    required this.borderRadius,
    this.verticalOffset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - squareSize) / 2;
    final double top = (size.height - squareSize) / 2 - verticalOffset;
    final Rect rect = Rect.fromLTWH(left, top, squareSize, squareSize);

    // Define the linear gradient
    final gradient = LinearGradient(
      colors: [Color(0xFF06ED62), Color(0xFF04ABDC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // Paint for the gradient shadow
    final Paint shadowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      shadowPaint,
    );

    // Paint for the gradient main border
    final Paint borderPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}