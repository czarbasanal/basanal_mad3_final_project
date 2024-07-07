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
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text("Register"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(OnboardingScreen.route);
            }
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              onSubmit();
            },
            child: const Text("Register"),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextFormField(
                    decoration: decoration.copyWith(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email)),
                    focusNode: emailFn,
                    controller: email,
                    onEditingComplete: () {
                      passwordFn.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Email is required"),
                      EmailValidator(errorText: "Enter a valid email address"),
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: obfuscatePassword,
                    decoration: decoration.copyWith(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obfuscatePassword = !obfuscatePassword;
                              });
                            },
                            icon: Icon(obfuscatePassword
                                ? Icons.remove_red_eye_rounded
                                : CupertinoIcons.eye_slash))),
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
                          errorText: "Password cannot exceed 72 characters"),
                      PatternValidator(
                          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                          errorText:
                              'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.')
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: obfuscateConfirmPassword,
                    decoration: decoration.copyWith(
                        labelText: "Confirm Password",
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obfuscateConfirmPassword =
                                    !obfuscateConfirmPassword;
                              });
                            },
                            icon: Icon(obfuscateConfirmPassword
                                ? Icons.remove_red_eye_rounded
                                : CupertinoIcons.eye_slash))),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  InputDecoration get decoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.black87, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1),
      ));
}
