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

  void goToProfileTab() {
    _onItemTapped(2); // ProfileApp is at index 2
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
              _buildTab(
                index: 0,
                icon: FontAwesomeIcons.clock,
                label: "History",
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
                      size: _currentIndex == 1 ? 28 : 24,
                    ),
                    onPressed: () => _onItemTapped(1),
                  ),
                ),
              ),

              // Profile Tab
              _buildTab(
                index: 2,
                icon: FontAwesomeIcons.link,
                label: "Connect",
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to reduce duplicate code
  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _currentIndex == index ? 22 : 18,
            color: _currentIndex == index ? Color(0xFF0092B4) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: _currentIndex == index ? 12 : 10,
              fontWeight:
              _currentIndex == index ? FontWeight.w600 : FontWeight.normal,
              color: _currentIndex == index ? Color(0xFF0092B4) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
