import 'package:basanal_mad3_final_project/controllers/auth_controller.dart';
import 'package:basanal_mad3_final_project/routing/router.dart';
import 'package:basanal_mad3_final_project/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/test_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //AuthController.initialize();
  //GlobalRouter.initialize();
  //await AuthController.I.loadSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //routerConfig: GlobalRouter.I.router,
      title: 'Map Journal App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: MapScreen(),
    );
  }
}
