import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/button.dart';
import 'package:nexus/pages/home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

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
  void initState() {
    super.initState();

    // user needs to be created before
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    // call after email verification
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();

    setState(() => canResendEmail = false);
    await Future.delayed(const Duration(seconds: 5));
    setState(() => canResendEmail = true);
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      // ignore: prefer_const_constructors
      ? HomePage()
      : Scaffold(
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
                      const Icon(
                        Icons.email_outlined,
                        size: 100,
                      ),

                      const SizedBox(
                        height: 50,
                      ),

                      //welcome back message

                      Text(
                        "Un email de vérification a été envoyé à votre adresse. Veuillez vérifier votre boîte de réception et cliquer sur le lien de vérification pour activer votre compte.",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      // sign in button

                      MyButton(
                        onTap: canResendEmail ? sendVerificationEmail : null,
                        text: 'Resend Email',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
}
