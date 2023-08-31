// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, depend_on_referenced_packages, use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/button.dart';
import 'package:nexus/components/square_tile.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  Future signIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.pop(context);
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

  @override
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
                  Icon(
                    Icons.lock,
                    size: 100,
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  //welcome back message
                  Text(
                    "Welcome back, you've been missed",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 25),

                  //email textfield
                  MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),

                  //Password textfield
                  MyTextField(
                    controller: passwordTextController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    onTap: signIn,
                    text: 'Sign In',
                  ),

                  const SizedBox(height: 50),
                  // or continue with

                  //  Padding(
                  //    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  //    child: Row(
                  //      children: [
                  //        Expanded(
                  //          child: Divider(
                  //            thickness: 0.5,
                  //            color: Colors.grey[400],
                  //          ),
                  //        ),
                  //        const SizedBox(
                  //          width: 7,
                  //        ),
                  //        Text('Or continue with',
                  //            style: TextStyle(
                  //              color: Colors.grey[700],
                  //            )),
                  //        const SizedBox(
                  //          width: 7,
                  //        ),
                  //        Expanded(
                  //          child: Divider(
                  //            thickness: 0.5,
                  //            color: Colors.grey[400],
                  //          ),
                  //        ),
                  //      ],
                  //    ),
                  //  ),

                  //const SizedBox(height: 50),
                  //    Row(
                  //      mainAxisAlignment: MainAxisAlignment.center,
                  //      children: [
                  //        // google button
                  //        SquareTile(
                  //          onTap: () => AuthService().signInWithGoogle(),
                  //          imagePath: 'assets/images/google.png',
                  //        ),
                  //        const SizedBox(
                  //          width: 10,
                  //        ),
                  //        // apple button
                  //        SquareTile(
                  //          onTap: () {},
                  //          imagePath: 'assets/images/apple.png',
                  //        ),
                  //      ],
                  //    ),

                  //const SizedBox(height: 50),

                  // not a member ? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not a member ?",
                          style: TextStyle(
                            color: Colors.grey[700],
                          )),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text("Register now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            )),
                      ),
                      const SizedBox(height: 100),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
