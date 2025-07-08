import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HomeTabNavigator.dart';
import 'barcode_scanner_view.dart';
import 'FAQs_page.dart';
import 'history.dart';
class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Switch to scanner tab using global key
        HomeTabNavigator.globalKey.currentState?.goToScannerTab();
        return false; // Don't pop this page manually
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50), // Adjust this value to move the AppBar down
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Connect',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 20), // Adjust spacing below the title
              Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Info Section
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2), // Border around the image
                            borderRadius: BorderRadius.circular(12), // Adjust for curved corners
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12), // Apply curve to the image
                            child: Image.asset(
                              'images/secuqr_main_logo.png', // Replace with your image asset
                              width: 70,  // Adjust size as needed
                              height: 70, // Adjust size as needed
                              fit: BoxFit.cover, // Ensure the image fills the container properly
                            ),
                          ),
                        ),

                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SecuQR India',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'info@SecuQR.com',
                              style:
                              TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // List of Options
                    // Social Media & Contact Section
                    Text(
                      'Connect with us',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.linkedin, color: Colors.blue[700]),
                          onPressed: () {
                            launchUrl(Uri.parse('https://www.linkedin.com/company/secuqr'));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.instagram, color: Colors.pink),
                          onPressed: () {
                            launchUrl(Uri.parse('https://www.instagram.com/secuqr'));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                          onPressed: () {
                            launchUrl(Uri.parse('https://www.facebook.com/secuqr'));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.xTwitter, color: Colors.black),
                          onPressed: () {
                            launchUrl(Uri.parse('https://www.twitter.com/secuqr'));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.black54),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'info@SecuQR.com',
                                );
                                launchUrl(emailLaunchUri);
                              },
                              child: Text(
                                'info@SecuQR.com',
                                style: TextStyle(
                                  color: Colors.blue,
                                  // decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, color: Colors.black54),
                            SizedBox(width: 10),
                            Row(
                              children: [
                                Text(
                                  '🇮🇳 ',
                                  style: TextStyle(fontSize: 20), // Adjust size if needed
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse('tel:+919894463440'));
                                  },
                                  child: Text(
                                    '9894463440',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, color: Colors.black54),
                            SizedBox(width: 10),
                            Row(
                              children: [
                                Text(
                                  '🇺🇸 ',
                                  style: TextStyle(fontSize: 20), // Adjust size if needed
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse('tel:+17862737417'));
                                  },
                                  child: Text(
                                    '786-273-7417',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.white,
        //   child: Container(
        //     height: 70,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         // History Tab
        //         Container(
        //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: GestureDetector(
        //             onTap: () {
        //               Navigator.pushReplacement(
        //                 context,
        //                 MaterialPageRoute(builder: (context) => Scan_history_Page()),
        //               );
        //
        //             },
        //             child: Column(
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 SizedBox(
        //                   width: 24,
        //                   height: 24,
        //                   child: Icon(FontAwesomeIcons.clock, size: 24),
        //                 ),
        //                 Text(
        //                   "History",
        //                   style: TextStyle(fontSize: 10),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //
        //         // QR Code Scanner Tab
        //         Container(
        //           width: 48,
        //           height: 48,
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: IconButton(
        //             icon: Icon(Icons.qr_code_scanner, size: 30),
        //             onPressed: () {
        //               Navigator.pushReplacement(
        //                 context,
        //                 MaterialPageRoute(builder: (context) => BarcodeScannerView()),
        //               );
        //
        //             },
        //           ),
        //         ),
        //
        //         // Connect Tab - Selected (Highlighted)
        //         Container(
        //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //           decoration: BoxDecoration(
        //             color: const Color(0xFF0092B4),
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               SizedBox(
        //                 width: 24,
        //                 height: 24,
        //                 child: Icon(
        //                   FontAwesomeIcons.link,
        //                   size: 24,
        //                   color: Colors.white,
        //                 ),
        //               ),
        //               Text(
        //                 "Connect",
        //                 style: TextStyle(fontSize: 10, color: Colors.white),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

      ),
    );
  }
}


class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  ProfileOption({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black54),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}