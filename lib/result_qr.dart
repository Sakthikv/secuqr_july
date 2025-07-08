import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'colors/appcolor.dart';
import 'dart:convert';
import 'barcode_scanner_view.dart';
import 'package:image/image.dart' as img;

class DisplayImagePage extends StatefulWidget {
  final File imageFile;
  final InputImage inputImage;

  const DisplayImagePage({
    super.key,
    required this.inputImage,
    required this.imageFile,
  });

  @override
  DisplayImagePageState createState() => DisplayImagePageState();
}

class DisplayImagePageState extends State<DisplayImagePage> {
  late CameraController cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isChecking = true;
  double _loadingProgress = 0.0;
  Uint8List? _croppedImageBytes;
  int? _qrStatus;

  @override
  void initState() {
    super.initState();
    _checkForQRCode(context, widget.inputImage, widget.imageFile);
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _checkForQRCode(BuildContext context, InputImage inputImage,
      File imagefile) async {
    final Uint8List imageBytes = await imagefile.readAsBytes();
    setState(() {
      _isChecking = true;
      _loadingProgress = 0.0;
    });
    try {
      final List<Barcode> barcodes =
      await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final Barcode qrCode = barcodes.first;
        final Rect boundingBox = qrCode.boundingBox;
        final img.Image? originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          final int cropX = boundingBox.left.toInt();
          final int cropY = boundingBox.top.toInt();
          final int cropWidth = boundingBox.width.toInt();
          final int cropHeight = boundingBox.height.toInt();
          final int adjustedX =
          cropX.clamp(0, originalImage.width - cropWidth);
          final int adjustedY =
          cropY.clamp(0, originalImage.height - cropHeight);
          final img.Image croppedImage = img.copyCrop(
            originalImage,
            x: adjustedX - 35,
            y: adjustedY - 35,
            width: cropWidth + 70,
            height: cropHeight + 70,
          );
          // Resize for clearer image
          final img.Image resizedImage =
          img.copyResize(croppedImage, width: 500, height: 500);
          setState(() {
            _croppedImageBytes =
                Uint8List.fromList(img.encodePng(resizedImage));
            _loadingProgress = 0.75;
          });
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _loadingProgress = 1.0;
          });
          await sendImageToApi(_croppedImageBytes!);
        }
      } else {
        // No QR code found, display the default image
        setState(() {
          _croppedImageBytes = null;
          _loadingProgress = 1.0;
        });
      }
    } catch (e) {
      print('Error: $e');
      _navigateBackToScanner();
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> sendImageToApi(Uint8List imageBytes) async {
    final url = Uri.parse('https://secuqr.xyz/chekit');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'scnd_img',
        imageBytes,
        filename: 'scanned_image.png',
        contentType: MediaType('image', 'png'),
      ),
    );
    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      if (responseData.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseData.body);
        final int status = data['status'] ?? -1;
        setState(() {
          _qrStatus = status;
        });

        // Show the result dialog after API response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _buildResultContentDialog(context, imageBytes);
          },
        );
      } else {
        _navigateBackToScanner();
      }
    } catch (e) {
      print('API Error: $e');
      _navigateBackToScanner();
    }
  }

  Widget _buildResultContentDialog(BuildContext context,
      Uint8List? qrImageBytes) {
    Color resultColor;
    IconData resultIcon;
    String above;
    IconData resultIcon1 = Icons.shield_rounded;
    String resultTitle;
    String resultMessage1;
    String resultMessage2;

    switch (_qrStatus) {
      case 1: // Legitimate QR Code
        resultColor = Colors.green;
        above = "This product is";
        resultIcon = Icons.check_circle;
        resultTitle = "Genuine";
        resultMessage1 = "Rest assured, you are purchasing";
        resultMessage2 = "an authentic and verified product.";
        break;
      case 0: // Counterfeit QR Code
        resultColor = Colors.red;
        above = "This product may be";
        resultIcon = Icons.cancel;
        resultTitle = "Counterfeit";
        resultMessage1 = "This is not an authenticated";
        resultMessage2 = "SecuQR product. Please avoid using or purchasing it.";
        break;
      default: // Error or Unknown
        resultColor = Colors.orange;
        above = "This product is";
        resultIcon = Icons.error;
        resultTitle = "Not Recognized";
        resultMessage1 = "Detection Error";
        resultMessage2 = "Please try again";
        break;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (qrImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                qrImageBytes,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                resultIcon1,
                size: 60,
                color: resultColor,
              ),
              Icon(
                resultIcon,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            above,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            resultTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            resultMessage1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            resultMessage2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _navigateBackToScanner,
            icon: Icon(Icons.camera_alt_outlined),
            label: Text(
              "Scan again",
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateBackToScanner() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerView(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Container(
                  height: screenWidth * 0.6,
                  width: screenWidth * 0.6,
                  margin: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: screenWidth * 0.02,
                        spreadRadius: screenWidth * 0.01,
                      ),
                    ],
                  ),
                  child: _croppedImageBytes != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    child: Image.memory(
                      _croppedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'images/no_qr.png', // Default image when no QR is found
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Card(
                  elevation: screenWidth * 0.02,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.04,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isChecking)
                          Column(
                            children: [
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: 0.0, end: _loadingProgress),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, double value, child) {
                                  return CircularPercentIndicator(
                                    radius: screenWidth * 0.15,
                                    lineWidth: screenWidth * 0.015,
                                    percent: value,
                                    center: Text(
                                      "${(value * 100).toInt()}%",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.black),
                                    ),
                                    progressColor: Colors.blue,
                                    backgroundColor: Colors.white,
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "Analyzing QR code...",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
                        else
                          _buildResultContentDialog(context,_croppedImageBytes),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

}