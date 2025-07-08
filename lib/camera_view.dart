import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:secuqr1/user_profile.dart';
import 'barcode_scanner_view.dart';
import 'border_painter.dart';
import 'square_clipper.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.initialCameraLensDirection = CameraLensDirection.back,
    required this.onBarcodeCenterUpdated,
    required this.qrCodeState,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final CameraLensDirection initialCameraLensDirection;
  final void Function(Offset qrCenter) onBarcodeCenterUpdated;
  final QRCodeState qrCodeState;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final topContentOffset = screenHeight * 0.05;
    final squareOffset = screenHeight * 0.0001; // 👈 Moved down


    // Square frame properties
    final squareSize = screenWidth * 0.8;
    final borderRadius = screenWidth * 0.05;
    final borderWidth = screenWidth * 0.01;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: (TapDownDetails details) => _onTapToFocus(details),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: _controller == null || !_controller!.value.isInitialized
                    ? Container()
                    : CameraPreview(
                  _controller!,
                  child: widget.customPaint,
                ),
              ),
            ),
          ),

          ClipPath(
            clipper: RoundedSquareClipper(
              squareSize: squareSize,
              borderRadius: borderRadius,
              verticalOffset: squareOffset,
            ),
            child: Container(
              color: Colors.white,
            ),
          ),

          CustomPaint(
            painter: SquareBorderPainter(
              squareSize: squareSize,
              borderWidth: borderWidth,
              borderColor: const Color(0xFF0092B4),
              borderRadius: borderRadius,
              verticalOffset: squareOffset,
            ),
            size: Size(screenWidth, screenHeight),
          ),

          Positioned(
            top: topContentOffset,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: screenWidth * 0.05),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.01),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => userProfilePage(),
                          transitionDuration: const Duration(milliseconds: 20),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                            (route) => false,
                      );
                    },
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: screenWidth * 0.07,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/FUll_Lockup_Tagline_White.png',
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.05),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.black,
                    size: screenWidth * 0.07,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: topContentOffset + screenWidth * 0.22,
            left: 0,
            right: 0,
            child: Text(
              'Buy with Confidence — 100% Original Items',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.039,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            top: topContentOffset + screenWidth * 0.29,
            left: 0,
            right: 0,
            child: Text(
              'Verify Real Or Fake in Seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.039,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            top: topContentOffset + screenWidth * 0.35,
            left: 0,
            right: 0,
            child: Text(
              'Position the QR Code to Capture its Image Clearly',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.036,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Positioned(
            top: squareOffset + screenWidth * 0.3,
            left: (screenWidth - squareSize) / 2,
            child: SizedBox(
              width: squareSize,
              height: squareSize,
            ),
          ),

          Positioned(
            top: squareOffset + screenWidth * 0.35 + squareSize + screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      FontAwesomeIcons.clock,
                      color: widget.qrCodeState == QRCodeState.waiting ? Colors.blue : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: widget.qrCodeState == QRCodeState.scanning ? Colors.blue : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    Icon(
                      FontAwesomeIcons.circleCheck,
                      color: widget.qrCodeState == QRCodeState.successful ? Colors.green : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.025),
                  child: Text(
                    _getTextForState(widget.qrCodeState),
                    style: TextStyle(
                      fontSize: screenWidth * 0.040,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTextForState(QRCodeState state) {
    switch (state) {
      case QRCodeState.waiting:
        return "Awaiting QR code...";
      case QRCodeState.scanning:
        return "Scanning the QR code";
      case QRCodeState.successful:
        return "Scan is successful";
    }
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await _controller?.initialize().then((_) async {
      if (!mounted) return;
      await _controller?.startImageStream(_processCameraImage).then((_) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _onTapToFocus(TapDownDetails details) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    final double x = localPosition.dx / renderBox.size.width;
    final double y = localPosition.dy / renderBox.size.height;
    final Offset focusPoint = Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
    _controller?.setFocusPoint(focusPoint);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
}