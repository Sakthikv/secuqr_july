import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeTabNavigator.dart';
import 'barcode_scanner_view.dart';
import 'profile.dart';

class Scan_history_Page extends StatefulWidget {
  @override
  _Scan_history_PageState createState() => _Scan_history_PageState();
}

class _Scan_history_PageState extends State<Scan_history_Page>with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _scanHistory = [];
  String _selectedFilter = 'All'; // default filter
  String _selectedDateFilter = 'All';
  final List<String> _dateFilters = ['All', 'Today', 'This Week', 'This Month', 'This Year'];
  int count = 0;
  int counterfeitCount = 0;
  int genuineCount = 0;
  bool _isDialogOpen = false;


  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList('scanHistory') ?? [];
    setState(() {
      _scanHistory = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
      count = historyList.length;
      counterfeitCount =
          _scanHistory.where((item) => item['status'] == 'ALTERED').length;
      genuineCount =
          _scanHistory.where((item) => item['status'] == 'LEGITIMATE').length;
    });
  }

  bool _filterByDate(Map<String, dynamic> item) {
    if (_selectedDateFilter == 'All') return true;
    try {
      String rawDate = item['dateTime'];
      List<String> parts = rawDate.split(' ');
      if (parts.length < 2) return false;
      String datePart = parts[0]; // e.g., "2025-05-23"
      List<String> dateComponents = datePart.split('-');
      if (dateComponents.length != 3) return false;
      int itemYear = int.tryParse(dateComponents[0]) ?? 0;
      int itemMonth = int.tryParse(dateComponents[1]) ?? 0;
      int itemDay = int.tryParse(dateComponents[2]) ?? 0;
      DateTime now = DateTime.now();
      int nowYear = now.year;
      int nowMonth = now.month;
      int nowDay = now.day;
      switch (_selectedDateFilter) {
        case 'Today':
          return itemYear == nowYear && itemMonth == nowMonth && itemDay == nowDay;
        case 'This Week':
          int weekdayDiff = now.weekday - 1; // Monday is start of week
          DateTime startOfWeek = DateTime(now.year, now.month, now.day - weekdayDiff);
          DateTime itemDate = DateTime(itemYear, itemMonth, itemDay);
          return itemDate.isAfter(startOfWeek) || itemDate.isAtSameMomentAs(startOfWeek);
        case 'This Month':
          return itemYear == nowYear && itemMonth == nowMonth;
        case 'This Year':
          return itemYear == nowYear;
        default:
          return true;
      }
    } catch (e) {
      debugPrint("Error in filter by date: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final filteredList = _scanHistory
        .where((item) {
      bool matchesStatus = _selectedFilter == 'All' || item['status'] == _selectedFilter;
      bool matchesDate = _filterByDate(item);
      return matchesStatus && matchesDate;
    })
        .toList();

    return WillPopScope(
      onWillPop: () async {
        HomeTabNavigator.globalKey.currentState?.goToScannerTab();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello!',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.08,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    'SecuQR India',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: screenWidth * 0.005),
                                ),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.12,
                                  backgroundImage: AssetImage('images/secuqr_main_logo.png'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          FadeTransition(
                            opacity: _slideAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(_animationController),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatCard(
                                    icon: Icons.qr_code_scanner_outlined,
                                    label: 'Scanned',
                                    count: count,
                                    color: Colors.blue.shade50,
                                    isActive: _selectedFilter == 'All',
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'All';
                                      });
                                    },
                                  ),
                                  _buildStatCard(
                                    icon: Icons.error_outline,
                                    label: 'ALTERED',
                                    count: counterfeitCount,
                                    color: Colors.red.shade50,
                                    isActive: _selectedFilter == 'ALTERED',
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'ALTERED';
                                      });
                                    },
                                  ),
                                  _buildStatCard(
                                    icon: Icons.check_circle_outline,
                                    label: 'LEGITIMATE',
                                    count: genuineCount,
                                    color: Colors.green.shade50,
                                    isActive: _selectedFilter == 'LEGITIMATE',
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'LEGITIMATE';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scan History',
                                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.filter_list, color: Colors.black54),
                                color: Colors.white,
                                onSelected: (value) {
                                  setState(() {
                                    _selectedDateFilter = value;
                                  });
                                },
                                itemBuilder: (context) => _dateFilters.map((filter) {
                                  return PopupMenuItem<String>(
                                    value: filter,
                                    child: Text(filter),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // 🔽 PERFORMANCE-OPTIMIZED SECTION
                          Builder(
                            builder: (context) {
                              final filteredList = _scanHistory.where((item) {
                                bool matchesStatus = _selectedFilter == 'All' || item['status'] == _selectedFilter;
                                bool matchesDate = _filterByDate(item);
                                return matchesStatus && matchesDate;
                              }).toList();

                              if (filteredList.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Text(
                                      'No scan at that time',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = filteredList[index];
                                  return _buildScanItem(context, item);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildScanItem(BuildContext context, Map<String, dynamic> item) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final imageBytes = base64Decode(item['image']);
    final status = item['status'];
    final datetime = item['dateTime'];
    return GestureDetector(
      onTap: () {
        late Uint8List imageBytes;
        try {
          imageBytes = base64Decode(item['image']);
        } catch (e) {
          imageBytes = Uint8List(0); // fallback
        }
        _isDialogOpen = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => true,
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                      child: Image.memory(imageBytes, fit: BoxFit.contain),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: MediaQuery.of(context).size.width * 0.04),
                        children: [
                          TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'ALTERED'
                                  ? Colors.red
                                  : status == 'LEGITIMATE'
                                  ? Colors.green
                                  : Color(0xFFEED508),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Scanned: $datetime',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: MediaQuery.of(context).size.width * 0.035),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade600),
                      onPressed: () {
                        _isDialogOpen = false;
                        Navigator.of(context).pop();
                      },
                      child: Text("Close", style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.035)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.15,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                image: DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.035),
                      children: [
                        TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'ALTERED'
                                ? Colors.red
                                : status == 'LEGITIMATE'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text('Scanned: $datetime',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    double cardWidth = (MediaQuery.of(context).size.width - 40) / 3;
    double iconSize = cardWidth * 0.3;
    double fontSizeLabel = cardWidth * 0.12;
    double fontSizeCount = cardWidth * 0.15;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        splashColor: Colors.teal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? Colors.teal.withOpacity(0.2) : color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.teal : Colors.transparent,
              width: isActive ? 1.5 : 0,
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.teal),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSizeLabel,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '$count',
                style: TextStyle(fontSize: fontSizeCount),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (text == 'All Scans') {
              _selectedFilter = 'All';
            } else if (text == 'LEGITIMATE') {
              _selectedFilter = 'LEGITIMATE';
            } else {
              _selectedFilter = 'ALTERED';
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
          decoration: BoxDecoration(
            color: isActive ? Colors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            border: Border.all(color: Colors.teal, width: 1),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ),
      ),
    );
  }
}