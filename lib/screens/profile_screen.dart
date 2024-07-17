import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../controllers/auth_controller.dart';
import '../controllers/user_data_controller.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const name = 'Profile';

  final UserDataController _userDataController =
      GetIt.instance<UserDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
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
                    ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: profileImage),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: const Border(
                              bottom: BorderSide(color: Colors.black),
                              top: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.black),
                            )),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: () {
                            AuthController.instance.logout();
                          },
                          color: Colors.deepPurpleAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                      ),
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
