import 'package:basanal_mad3_final_project/screens/home_screen.dart';
import 'package:basanal_mad3_final_project/screens/journal_entries_screen.dart';
import 'package:basanal_mad3_final_project/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../routing/router.dart';
import '../controllers/user_data_controller.dart';
import '../services/information_service.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget? child;
  const ScreenWrapper({super.key, this.child});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int index = 0;

  List<String> routes = [
    HomeScreen.route,
    JournalEntriesScreen.route,
    ProfileScreen.route
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child ?? const Placeholder(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        useLegacyColorScheme: false,
        backgroundColor: Colors.white,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;

            GlobalRouter.I.router.go(routes[i]);
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map),
              activeIcon: Icon(CupertinoIcons.map_fill),
              label: "Map"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
              label: "Journal"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: "Profile"),
        ],
      ),
    );
  }
}
