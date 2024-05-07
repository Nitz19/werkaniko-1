// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_rescue/src/widgets/text_widget.dart';
import 'package:motor_rescue/src/widgets/textfield_widget.dart';
import 'package:motor_rescue/src/widgets/toast_widget.dart';

import '../controllers/auth.dart';

class MechanicLogin extends StatefulWidget {
  const MechanicLogin({super.key});

  @override
  State<MechanicLogin> createState() => _MechanicLoginState();
}

late TextEditingController emailController;
late TextEditingController passwordController;

class _MechanicLoginState extends State<MechanicLogin> {
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = false;
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  // @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   //emailController.removeListener(_validateForm);
  //   //passwordController.removeListener(_validateForm);
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }

  void _validateForm() {
    setState(() {
      isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff24688e)),
        toolbarHeight: 75,
        leadingWidth: 75,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              SizedBox(height: size.height * 0.05),
              buildEmail(),
              SizedBox(height: size.height * 0.03),
              buildPassword(),
              SizedBox(height: size.height * 0.03),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                width: double.infinity,
                height: 75,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black),
                  ),
                  onPressed:
                      isButtonEnabled ? () => _logInMechanic(context) : null,
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: ((context) {
                        final formKey = GlobalKey<FormState>();
                        final TextEditingController emailController =
                            TextEditingController();

                        return AlertDialog(
                          title: TextWidget(
                            text: 'Forgot Password',
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFieldWidget(
                                  hint: 'Email',
                                  textCapitalization: TextCapitalization.none,
                                  inputType: TextInputType.emailAddress,
                                  label: 'Email',
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email address';
                                    }
                                    final emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: (() {
                                Navigator.pop(context);
                              }),
                              child: TextWidget(
                                text: 'Cancel',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: (() async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    Navigator.pop(context);
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: emailController.text);
                                    showToast(
                                        'Password reset link sent to ${emailController.text}');
                                  } catch (e) {
                                    String errorMessage = '';

                                    if (e is FirebaseException) {
                                      switch (e.code) {
                                        case 'invalid-email':
                                          errorMessage =
                                              'The email address is invalid.';
                                          break;
                                        case 'user-not-found':
                                          errorMessage =
                                              'The user associated with the email address is not found.';
                                          break;
                                        default:
                                          errorMessage =
                                              'An error occurred while resetting the password.';
                                      }
                                    } else {
                                      errorMessage =
                                          'An error occurred while resetting the password.';
                                    }

                                    showToast(errorMessage);
                                    Navigator.pop(context);
                                  }
                                }
                              }),
                              child: TextWidget(
                                text: 'Continue',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  },
                  child: TextWidget(
                    text: 'Forgot Password?',
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     const Text(
              //       "Don't have an account? ",
              //       style: TextStyle(fontSize: 15),
              //     ),
              //     GestureDetector(
              //       onTap: () => GoRouter.of(context).go('/mechanicSignup'),
              //       child: const Text(
              //         'Signup',
              //         style: TextStyle(
              //           fontSize: 15,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.blue,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Image(
                image: AssetImage('assets/images/mechanic.png'),
                height: size.height * 0.4,
                fit: BoxFit.cover,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildEmail() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
            ),
          ],
        ),
        height: 60,
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.email,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Email',
          ),
        ),
      ),
    ],
  );
}

Widget buildPassword() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
            ),
          ],
        ),
        height: 60,
        child: TextField(
          obscureText: true,
          controller: passwordController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Password',
          ),
        ),
      ),
    ],
  );
}

//---------------------------------------------------

void _logInMechanic(BuildContext context) async {
  if (emailController.text.isEmpty) {
    print('email empty');
  } else if (passwordController.text.isEmpty) {
    //show error
  }

  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  String result = await AuthMethods().logInDriver(
    email: emailController.text,
    password: passwordController.text,
  );
  if (result == 'success') {
    print(result);
    GoRouter.of(context).go('/mechanic');
  } else {
    print(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: Colors.green,
      ),
    );
  }

  GoRouter.of(context).pop();
}
