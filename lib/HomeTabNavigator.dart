import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'barcode_scanner_view.dart';
import 'history.dart';
import 'profile.dart';

class HomeTabNavigator extends StatefulWidget {
  static final GlobalKey<_HomeTabNavigatorState> globalKey =
  GlobalKey<_HomeTabNavigatorState>();

  HomeTabNavigator({Key? key}) : super(key: globalKey);

  @override
  _HomeTabNavigatorState createState() => _HomeTabNavigatorState();
}


class _HomeTabNavigatorState extends State<HomeTabNavigator> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    Scan_history_Page(),
    BarcodeScannerView(),
    ProfileApp(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // NEW: Expose this method for external tab control
  void goToScannerTab() {
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // History Tab
              // History Tab
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.clock,
                      size: _currentIndex == 0 ? 22 : 18, // ⬅️ size change
                      color: _currentIndex == 0 ? Color(0xFF0092B4) : Colors.grey,
                    ),
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: _currentIndex == 0 ? 12 : 10, // ⬅️ size change
                        fontWeight: _currentIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                        color: _currentIndex == 0 ? Color(0xFF0092B4) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

// Scanner Tab - Always Highlighted
              SizedBox(
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0092B4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: _currentIndex == 1 ? 28 : 24, // optional zoom here too
                    ),
                    onPressed: () => _onItemTapped(1),
                  ),
                ),
              ),

// Profile Tab
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.link,
                      size: _currentIndex == 2 ? 22 : 18, // ⬅️ size change
                      color: _currentIndex == 2 ? Color(0xFF0092B4) : Colors.grey,
                    ),
                    Text(
                      "Connect",
                      style: TextStyle(
                        fontSize: _currentIndex == 2 ? 12 : 10, // ⬅️ size change
                        fontWeight: _currentIndex == 2 ? FontWeight.w600 : FontWeight.normal,
                        color: _currentIndex == 2 ? Color(0xFF0092B4) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}