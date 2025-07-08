import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'barcode_scanner_view.dart';
class DisplayImagePage extends StatelessWidget {
  final Uint8List croppedImageBytes;

  // Constructor to accept the image bytes
  DisplayImagePage({required this.croppedImageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Increased height to create more space above
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black), // Custom back button
            onPressed: () {
              // When the back button is pressed, pop the current page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerView(),
                ),
                    (route) => false,
                // Remove all previous routes
              );
            },
          ),
          title: Text(
            'Display Image',
            style: TextStyle(color: Colors.black), // Title color
          ),
          centerTitle: true, // Center the title if needed
        ),
      ),
      body: Center(
        child: croppedImageBytes.isNotEmpty
            ? Image.memory(croppedImageBytes)  // Display the image using Image.memory
            : CircularProgressIndicator(),  // Show a loading indicator if no image
      ),
    );
  }
}
