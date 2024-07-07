import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../auth/onboarding_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_data_controller.dart';
import '../models/user.dart';
import '../routing/router.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const name = 'Profile';

  final UserDataController _userDataController =
      GetIt.instance<UserDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<UserModel?>(
              valueListenable: _userDataController.userModelNotifier,
              builder: (context, UserModel? user, child) {
                if (user == null) {
                  return Text("No user data available");
                }
                Widget profileImage = user.profilePictureUrl.isNotEmpty
                    ? Image.network(user.profilePictureUrl,
                        width: 100, height: 100, fit: BoxFit.cover)
                    : Image.asset('lib/assets/profile-placeholder.png',
                        width: 100, height: 100);
                return Column(
                  children: <Widget>[
                    Text('Name: ${user.name}'),
                    Text('Email: ${user.email}'),
                    profileImage,
                    ElevatedButton(
                      onPressed: () async {
                        await AuthController.instance.logout();
                        GlobalRouter.I.router.go(OnboardingScreen.route);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
