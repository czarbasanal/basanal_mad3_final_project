import 'package:basanal_mad3_final_project/auth/onboarding_screen.dart';
import 'package:basanal_mad3_final_project/controllers/auth_controller.dart';
import 'package:basanal_mad3_final_project/controllers/user_data_controller.dart';
import 'package:basanal_mad3_final_project/routing/router.dart';
import 'package:basanal_mad3_final_project/services/firestore_service.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/test_map_screen.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AuthController.initialize();
  GlobalRouter.initialize();
  UserDataController.initialize();
  FirestoreService.initialize();
  await AuthController.instance.loadSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        SizeConfig().init(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: GlobalRouter.I.router,
          title: 'Map Journal App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
