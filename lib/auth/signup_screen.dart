import 'package:basanal_mad3_final_project/auth/onboarding_screen.dart';
import 'package:basanal_mad3_final_project/controllers/auth_controller.dart';
import 'package:basanal_mad3_final_project/dialogs/waiting_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  static const String route = "/register";
  static const String name = "Register";
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController email, password, confirmPassword;
  late FocusNode emailFn, passwordFn, confirmPasswordFn;

  bool obfuscatePassword = true;
  bool obfuscateConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    emailFn = FocusNode();
    passwordFn = FocusNode();
    confirmPasswordFn = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    emailFn.dispose();
    passwordFn.dispose();
    confirmPasswordFn.dispose();
  }

  void onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      WaitingDialog.show(context,
          future: AuthController.instance
              .register(email.text.trim(), password.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(OnboardingScreen.route);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics:
                    BouncingScrollPhysics(), // Add smooth scrolling physics
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: decoration.copyWith(
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.black87)),
                        focusNode: emailFn,
                        controller: email,
                        onEditingComplete: () {
                          passwordFn.requestFocus();
                        },
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Email is required"),
                          EmailValidator(
                              errorText: "Enter a valid email address"),
                        ]).call,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obfuscatePassword,
                        decoration: decoration.copyWith(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.black87),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obfuscatePassword = !obfuscatePassword;
                                  });
                                },
                                icon: Icon(
                                  obfuscatePassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: Colors.grey.shade500,
                                ))),
                        focusNode: passwordFn,
                        controller: password,
                        onEditingComplete: () {
                          confirmPasswordFn.requestFocus();
                        },
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Password is required"),
                          MinLengthValidator(12,
                              errorText:
                                  "Password must be at least 12 characters long"),
                          MaxLengthValidator(128,
                              errorText:
                                  "Password cannot exceed 72 characters"),
                          PatternValidator(
                              r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                              errorText:
                                  'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.')
                        ]).call,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obfuscateConfirmPassword,
                        decoration: decoration.copyWith(
                            labelText: "Confirm Password",
                            labelStyle: const TextStyle(color: Colors.black87),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obfuscateConfirmPassword =
                                        !obfuscateConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obfuscateConfirmPassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  color: Colors.grey.shade500,
                                ))),
                        focusNode: confirmPasswordFn,
                        controller: confirmPassword,
                        onEditingComplete: () {
                          confirmPasswordFn.unfocus();
                        },
                        validator: (value) {
                          if (value != password.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      Container(
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
                            onSubmit();
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
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade400),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Or continue with',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                'lib/assets/google-icon.webp',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            onTap: () {
                              print('Continue with google');
                            },
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                'lib/assets/github-icon.png',
                                width: 32,
                                height: 32,
                              ),
                            ),
                            onTap: () {
                              print('Continue with github');
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final OutlineInputBorder _baseBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey.shade400),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );

  InputDecoration get decoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ));
}
