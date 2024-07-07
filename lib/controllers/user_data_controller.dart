import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/user.dart';

class UserDataController with ChangeNotifier {
  ValueNotifier<UserModel?> userModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot>? userStream;

  static void initialize() {
    GetIt.instance.registerSingleton<UserDataController>(UserDataController());
  }

  void setUserModel(UserModel? user) {
    userModelNotifier.value = user;
    notifyListeners();
    if (user != null) {
      listen(user.id);
    } else {
      userStream?.cancel();
      userStream = null;
    }
  }

  void listen(String uid) {
    userStream ??= FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .listen(onDataChange);
  }

  void onDataChange(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final userModel = UserModel.fromMap(data, snapshot.id);
        setUserModel(userModel);
      }
    }
  }

  @override
  void dispose() {
    userStream?.cancel();
    super.dispose();
  }
}
