// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:ddetect/account.dart';
import 'package:ddetect/detailsfill.dart';
import 'package:ddetect/fft.dart';
import 'package:ddetect/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  Future<bool> onBackPress() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );

    _checkDetailsAdded();
  }

  Future<void> _checkDetailsAdded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool detailsAdded = prefs.getBool('detailsAdded2') ?? false;

    if (!detailsAdded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AddDetails()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const CalculateFFT(),
      const ReportPage(),
      const MyAccount(),
    ];

    Color blueColor = Colors.blue;

    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65.0,
          backgroundColor: blueColor,
          elevation: 1.5,
          title: const Text(
            "DDetect",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 20.0,
                bottom: 8.0,
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(1.0),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/login.png",
                      width: 45.0,
                      height: 45.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: SizedBox(
          height: 75.0,
          child: GNav(
            tabBorderRadius: 12,
            tabActiveBorder: Border.all(color: Colors.black, width: 1),
            gap: 8,
            color: Colors.grey[800],
            activeColor: Colors.blue,
            iconSize: 28,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            tabs: const [
              GButton(
                icon: LineIcons.home,
                text: 'Home',
              ),
              GButton(
                icon: LineIcons.file,
                text: 'Reports',
              ),
              GButton(
                icon: Icons.account_circle_outlined,
                text: 'Account',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
