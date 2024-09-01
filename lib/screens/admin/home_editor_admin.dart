import 'package:flutter/material.dart';
import 'package:pest_control_flutter/screens/admin/completed_admin.dart';
import 'package:pest_control_flutter/screens/admin/in_progress_admin.dart';
import 'package:pest_control_flutter/screens/admin/profile_admin_detail.dart';
import 'home_services_admin.dart';

class MyHomePageAdmin extends StatefulWidget {
  const MyHomePageAdmin({Key? key}) : super(key: key);

  @override
  State<MyHomePageAdmin> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePageAdmin> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageAdmin(),
    const InProgressAdmin(),
    const CompletedAdmin(),
    const ProfileAdmin()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(.40),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
        items:const [
          BottomNavigationBarItem(
            label:'Request',
            icon: Icon(Icons.request_quote_outlined),
          ),
          BottomNavigationBarItem(
            label: 'In Progress',
            icon: Icon(Icons.timer),
          ),
          BottomNavigationBarItem(
            label: 'Completed',
            icon: Icon(Icons.notes),
          ),BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
