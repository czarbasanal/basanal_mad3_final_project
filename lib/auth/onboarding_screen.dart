import 'package:basanal_mad3_final_project/auth/login_screen.dart';
import 'package:basanal_mad3_final_project/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/router.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = "/";
  static const String name = "Onboarding Screen";
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Map Journal App',
              style: TextStyle(
                fontSize: 32,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                GlobalRouter.I.router.go(RegisterScreen.route);
              },
              child: Text('Sign up with email'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                GlobalRouter.I.router.go(LoginScreen.route);
              },
              child: Text('Continue with google'),
            ),
          ],
        ),
      ),
    );
  }
}
