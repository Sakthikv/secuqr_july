import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/services.dart';
import 'HomeTabNavigator.dart';
import 'barcode_scanner_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global list of cameras
List<CameraDescription> cameras = [];
const platform = MethodChannel('com.example.yourapp/camera_stabilization');

Future<void> enableStabilization() async {



  try {
    await platform.invokeMethod('enableStabilization');
  } on PlatformException catch (e) {
    print("Failed to enable stabilization: '${e.message}'.");
  }
}

// Singleton Service for Camera
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  late CameraController cameraController;

  Future<void> initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        cameras = await availableCameras();
      }

      // Pick back camera by default
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await cameraController.initialize();
      await cameraController.startImageStream((image) {});
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> disposeCamera() async {
    await cameraController.stopImageStream();
    await cameraController.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize camera early
  await CameraService().initializeCamera();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));

  // runApp(
  //   DevicePreview(
  //     enabled: !bool.fromEnvironment('dart.vm.product'), // Enable in debug mode only
  //     builder: (context) => MyApp(isLoggedIn: isLoggedIn), // Your app widget
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? HomeTabNavigator() : LoginPage(),
    );
  }
}
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic dimensions
    final logoHeight = screenHeight * 0.15; // 15% of screen height
    final titleFontSize = screenWidth * 0.08; // 8% of screen width
    final subtitleFontSize = screenWidth * 0.04; // 4% of screen width
    final buttonHeight = screenHeight * 0.07; // 7% of screen height
    final buttonWidth = screenWidth * 0.8; // 80% of screen width
    final iconSize = screenWidth * 0.07; // 7% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'images/secuqr_main_logo1.png',
                height: logoHeight, // Dynamic height
              ),
              SizedBox(height: screenHeight * 0.01), // Reduced space between logo and title

              // Title with ® symbol
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SecuQR',
                    style: TextStyle(
                      fontSize: titleFontSize, // Dynamic font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -titleFontSize * 0.2), // Adjust position dynamically
                    child: Text(
                      '®',
                      style: TextStyle(
                        fontSize: titleFontSize * 0.6, // Smaller than the title
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.01), // Reduced space between title and subtitle

              // Subtitle
              Text(
                'Trust in Every Scan',
                style: TextStyle(
                  fontSize: subtitleFontSize, // Dynamic font size
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.3), // Space before buttons

              // Google Button
              OutlinedButton.icon(
                onPressed: () {
                  // Add Google sign-in logic
                },
                icon: Icon(Icons.g_mobiledata, size: iconSize, color: Colors.black),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight),
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02), // Dynamic border radius
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Space between buttons

              // Apple Button
              OutlinedButton.icon(
                onPressed: () {
                  // Add Apple sign-in logic
                },
                icon: Icon(Icons.apple, size: iconSize, color: Colors.black),
                label: Text(
                  'Continue with Apple',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight),
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02), // Dynamic border radius
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Space between buttons

              // Guest Button
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeTabNavigator(),
                    ),
                  );
                },
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight),
                  backgroundColor: Color(0xFF0092B4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}