import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'coordinates_translator.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(
      this.barcodes,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      this.onBarcodeSizeChanged,
      Size size, // Add a callback for barcode size changes
      );

  final List<Barcode> barcodes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final void Function(double) onBarcodeSizeChanged; // Callback type

  @override
  void paint(Canvas canvas, Size size) {
    double maxBoundingBoxSize = 0;

    // Step 1: Darken the entire screen with reduced opacity for the background (making the QR area pop)
    final Paint backgroundPaint = Paint()
      ..color = const Color(0x66000000); // Dark background (opacity 0.6) to make QR code stand out
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Step 2: For each barcode detected, process the bounding box and apply lighting (brightness) effect
    for (final Barcode barcode in barcodes) {
      final left = translateX(
        barcode.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        barcode.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        barcode.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        barcode.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      final width = right - left;
      final height = bottom - top;
      final boundingBoxSize = width * height;

      if (boundingBoxSize > maxBoundingBoxSize) {
        maxBoundingBoxSize = boundingBoxSize;
      }

      // Step 3: Apply the "light effect" (brightness enhancement) to the QR code area
      final Paint brightnessPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset((left + right) / 2, (top + bottom) / 2), // Center of the barcode
          120.0, // Radius of the "light" effect (increase if necessary)
          [
            Colors.white.withOpacity(0.8), // Brighter center (80% opacity)
            Colors.transparent, // Gradual fade to transparency
          ],
          [0.0, 1.0], // Gradient stops (from light to transparent)
        );

      final Rect outsideRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final Path path = Path()..addRect(outsideRect);

      // Subtract the QR code area to preserve the light around it
    //  path.addRect(Rect.fromLTRB(left, top, right, bottom));
      path.fillType = PathFillType.evenOdd;

      // Step 4: Apply the lighting effect on QR code area
      // canvas.drawPath(path, brightnessPaint);

    //  Optional: Draw corner indicators (horizontal and vertical lines at each corner)
      final Paint cornerPaint = Paint()
        ..color = Colors.white // White color for the corner indicators
        ..strokeWidth = 4.0; // Thickness of the corner indicator lines

      // Draw horizontal and vertical lines at each corner of the barcode area
      // Top-left corner
      // canvas.drawLine(Offset(left - 10, top - 10), Offset(left + 20, top - 10),
      //     cornerPaint); // Top horizontal
      // canvas.drawLine(Offset(left - 10, top - 10), Offset(left - 10, top + 20),
      //     cornerPaint); // Left vertical
      //
      // // Top-right corner
      // canvas.drawLine(Offset(right + 10, top - 10),
      //     Offset(right - 20, top - 10), cornerPaint); // Top horizontal
      // canvas.drawLine(Offset(right + 10, top - 10),
      //     Offset(right + 10, top + 20), cornerPaint); // Right vertical
      //
      // // Bottom-left corner
      // canvas.drawLine(Offset(left - 10, bottom + 10),
      //     Offset(left + 20, bottom + 10), cornerPaint); // Bottom horizontal
      // canvas.drawLine(Offset(left - 10, bottom + 10),
      //     Offset(left - 10, bottom - 20), cornerPaint); // Left vertical
      //
      // // Bottom-right corner
      // canvas.drawLine(Offset(right + 10, bottom + 10),
      //     Offset(right - 20, bottom + 10), cornerPaint); // Bottom horizontal
      // canvas.drawLine(Offset(right + 10, bottom + 10),
      //     Offset(right + 10, bottom - 20), cornerPaint); // Right vertical
    }

    // Step 5: Notify the parent or controller about the maximum barcode size
    if (maxBoundingBoxSize > 0) {
      onBarcodeSizeChanged(maxBoundingBoxSize);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.barcodes != barcodes;
  }
}
