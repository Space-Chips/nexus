// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, depend_on_referenced_packages, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus/auth/policy_dialog.dart';
import 'package:nexus/components/button.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/pages/email_verification_page.dart';
import 'package:animations/animations.dart';

import '../components/square_tile.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmpasswordTextController = TextEditingController();
  final firstnameTextController = TextEditingController();
  final lastnameTextController = TextEditingController();
  final ageTextController = TextEditingController();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmpasswordTextController.dispose();
    firstnameTextController.dispose();
    lastnameTextController.dispose();
    ageTextController.dispose();
    super.dispose();
  }

  Future signUp() async {
    Future addUsersDetails(String firstName, String lastName, String password,
        String email, int age) async {
      await FirebaseFirestore.instance.collection('users').add({
        'address': "",
        'admin': false,
        'followers': [],
        'interests': [],
        'relationshipStatus': false,
        'joinDate': Timestamp.now(),
        'username': emailTextController.text.split('@')[0], // initial username
        'bio': 'Empty bio...', // initial empty bio
        'first name': firstName,
        'last name': lastName,
        'password': password,
        'website': "",
        'email': email,
        'age': age,
      });
    }

    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordTextController.text != confirmpasswordTextController.text) {
      // pop loading circle
      Navigator.pop(context);
      // show error to the user
      displayMessage("Passwords don't match");
      return;
    }

    try {
      // Add user Details
      addUsersDetails(
        firstnameTextController.text.trim(),
        lastnameTextController.text.trim(),
        passwordTextController.text.trim(),
        emailTextController.text.trim(),
        int.parse(
          ageTextController.text.trim(),
        ),
      );
      // create user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      // show error to user
      displayMessage(e.code);
    }
  }

  // display a dialog message
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  bool passwordConfirmed() {
    if (passwordTextController.text.trim() ==
        confirmpasswordTextController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  // ignore: annotate_overrides
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //login

                  const SizedBox(
                    height: 50,
                  ),

                  Text(
                    "HELLO THERE",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  //welcome back message
                  Text(
                    "If we tell people the brain is an app maybe they'll start using it.",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),

                  MyTextField(
                    controller: firstnameTextController,
                    hintText: 'First Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 24),

                  MyTextField(
                    controller: lastnameTextController,
                    hintText: 'Last Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 24),

                  MyTextField(
                    controller: ageTextController,
                    hintText: 'Age',
                    obscureText: false,
                  ),
                  const SizedBox(height: 24),

                  //email textfield
                  MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 24),

                  //pasword textfield
                  MyTextField(
                    controller: passwordTextController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  MyTextField(
                    controller: confirmpasswordTextController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // sign in button
                  MyButton(
                    onTap: signUp,
                    text: 'Sign Up',
                  ),
                  const SizedBox(height: 25),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "By creating an account, you are agreeing to our\n",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      children: [
                        TextSpan(
                            text: "\n"), // Add an empty TextSpan for spacing
                        TextSpan(
                          text: "Terms & Conditions ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showModal(
                                context: context,
                                configuration:
                                    FadeScaleTransitionConfiguration(),
                                builder: (context) {
                                  return PolicyDialog(
                                    mdFileName: 'terms_and_conditions.md',
                                  );
                                },
                              );
                            },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  // or continue with

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text('Or continue with',
                            style: TextStyle(
                              color: Colors.grey[700],
                            )),
                        const SizedBox(
                          width: 7,
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      SquareTile(
                        onTap: () {
                          displayMessage("C O M I N G  S O O N");
                        },
                        imagePath: 'assets/images/google.png',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      // apple button
                      SquareTile(
                        onTap: () {
                          displayMessage("C O M I N G  S O O N");
                        },
                        imagePath: 'assets/images/apple.png',
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),
                  // go to register page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Alredy have an account ?",
                          style: TextStyle(
                            color: Colors.grey[700],
                          )),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text("Login now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            )),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
