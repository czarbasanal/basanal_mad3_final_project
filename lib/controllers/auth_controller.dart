import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../enum/enum.dart';
import 'user_data_controller.dart';

class AuthController with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  static final UserDataController _userDataController =
      GetIt.instance<UserDataController>();
  static final FirestoreService _firestoreService =
      GetIt.instance<FirestoreService>();
  static AuthController get instance => GetIt.instance<AuthController>();

  late StreamSubscription<User?> currentAuthedUser;

  AuthState state = AuthState.unauthenticated;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  listen() {
    currentAuthedUser = _auth.authStateChanges().listen(handleUserChanges);
  }

  void handleUserChanges(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      state = AuthState.unauthenticated;
      await prefs.remove('userId');
    } else {
      state = AuthState.authenticated;
      await prefs.setString('userId', user.uid);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final UserModel userModel =
          await _firestoreService.getUser(userCredential.user!.uid);
      _userDataController.setUserModel(userModel);
    } catch (e) {
      print('Error logging in user: $e');
      throw Exception('Failed to log in');
    }
  }

  signInWithGoogle() async {
    GoogleSignInAccount? gSign = await _googleSignIn.signIn();
    if (gSign == null) throw Exception("No Signed in account");
    GoogleSignInAuthentication googleAuth = await gSign.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> register(String email, String password) async {
    try {
      final auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: '',
        email: email,
        profilePictureUrl: '',
      );

      await _firestoreService.createUser(newUser);
      _userDataController.setUserModel(newUser);
    } catch (e) {
      print('Error registering user: $e');
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.signOut();
    }
    await _auth.signOut();
    _userDataController.setUserModel(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> loadSession() async {
    listen();
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      try {
        final UserModel userModel = await _firestoreService.getUser(userId);
        _userDataController.setUserModel(userModel);
        handleUserChanges(FirebaseAuth.instance.currentUser);
      } catch (e) {
        print('Error loading user session: $e');
        handleUserChanges(null);
      }
    } else {
      handleUserChanges(null);
    }
  }
}
