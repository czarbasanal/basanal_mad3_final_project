import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../enum/enum.dart';

class AuthController with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  UserModel? _currentUser;
  final FirestoreService _firestoreService = GetIt.instance<FirestoreService>();

  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  static AuthController get I => GetIt.instance<AuthController>();

  AuthState state = AuthState.unauthenticated;
  StreamSubscription? _userSubscription;

  AuthController() {
    _auth.authStateChanges().listen((auth.User? user) async {
      if (user == null) {
        state = AuthState.unauthenticated;
        _currentUser = null;
        _userSubscription?.cancel();
        _userSubscription = null;
      } else {
        state = AuthState.authenticated;
        _userSubscription =
            _firestoreService.listenToUser(user.uid).listen((userModel) {
          _currentUser = userModel;
          notifyListeners();
        });
      }
    });
  }

  UserModel? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    try {
      auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _userSubscription?.cancel();
      _userSubscription = _firestoreService
          .listenToUser(userCredential.user!.uid)
          .listen((userModel) {
        _currentUser = userModel;
        state = AuthState.authenticated;
        notifyListeners();
      });
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> register(String email, String password) async {
    try {
      auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: '',
        email: email,
        profilePictureUrl: '',
      );
      await _firestoreService.addUser(newUser);

      _userSubscription?.cancel();
      _userSubscription = _firestoreService
          .listenToUser(userCredential.user!.uid)
          .listen((userModel) {
        _currentUser = userModel;
        state = AuthState.authenticated;
        notifyListeners();
      });
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState.unauthenticated;
    _currentUser = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    auth.User? user = _auth.currentUser;
    if (user != null) {
      _userSubscription?.cancel();
      _userSubscription =
          _firestoreService.listenToUser(user.uid).listen((userModel) {
        _currentUser = userModel;
        state = AuthState.authenticated;
        notifyListeners();
      });
    } else {
      state = AuthState.unauthenticated;
      notifyListeners();
    }
  }
}
