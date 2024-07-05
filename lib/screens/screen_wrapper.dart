import 'package:basanal_mad3_final_project/screens/home_screen.dart';
import 'package:basanal_mad3_final_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../routing/router.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget? child;
  const ScreenWrapper({super.key, this.child});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int index = 0;

  List<String> routes = [HomeScreen.route, ProfileScreen.route];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child ?? const Placeholder(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;

            GlobalRouter.I.router.go(routes[i]);
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
