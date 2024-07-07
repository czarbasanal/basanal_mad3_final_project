import 'package:animate_do/animate_do.dart';
import 'package:basanal_mad3_final_project/auth/login_screen.dart';
import 'package:basanal_mad3_final_project/auth/signup_screen.dart';
import 'package:flutter/material.dart';

import '../routing/router.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = "/";
  static const String name = "Onboarding";
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              "Welcome",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: Text(
                              "Automatic identity verification which enables you to verify your identity",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 15),
                            )),
                      ],
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'lib/assets/Illustration.png'))),
                        )),
                    Column(
                      children: <Widget>[
                        FadeInUp(
                            duration: const Duration(milliseconds: 1500),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              height: 60,
                              onPressed: () {
                                //login route
                                GlobalRouter.I.router.go(LoginScreen.route);
                              },
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(50)),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18),
                              ),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1600),
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
                                  //sign up route
                                  GlobalRouter.I.router.go(SignupScreen.route);
                                },
                                color: Colors.deepPurpleAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
