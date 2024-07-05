import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../enum/enum.dart';

class AuthController with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  UserModel? _currentUser;

  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  static AuthController get instance => GetIt.instance<AuthController>();

  static AuthController get I => GetIt.instance<AuthController>();

  AuthState state = AuthState.unauthenticated;

  AuthController() {
    _auth.authStateChanges().listen((auth.User? user) async {
      if (user == null) {
        state = AuthState.unauthenticated;
        _currentUser = null;
      } else {
        state = AuthState.authenticated;
        final doc = await FirestoreService.getUserById(user.uid);
        _currentUser =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        notifyListeners();
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
      final doc = await FirestoreService.getUserById(userCredential.user!.uid);
      _currentUser =
          UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      state = AuthState.authenticated;
      notifyListeners();
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
      await FirestoreService().addUser(newUser);

      state = AuthState.authenticated;
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    auth.User? user = _auth.currentUser;
    if (user != null) {
      final doc = await FirestoreService.getUserById(user.uid);
      _currentUser =
          UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
