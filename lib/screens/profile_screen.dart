import 'package:flutter/material.dart';

import '../auth/onboarding_screen.dart';
import '../controllers/auth_controller.dart';
import '../routing/router.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AuthController.I.logout();
            GlobalRouter.I.router.go(OnboardingScreen.route);
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
