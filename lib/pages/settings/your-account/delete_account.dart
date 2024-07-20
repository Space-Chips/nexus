// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/pages/home_page.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late String username;
  late String address;
  late String website;
  late String updatedValue; // Declare updatedValue as a class-level variable
  late bool admin;

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  final emailTextController = TextEditingController();
  final newPasswordTextController = TextEditingController();
  final verifyPasswordTextController = TextEditingController();

  bool showPosts = true;
  bool isFollowing = false;

  // Define the displayMessage method
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Future change_password() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailTextController.text);
      Fluttertoast.showToast(
        msg: 'Password reset email has been sent. Please check your inbox.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on FirebaseAuthException {
      Fluttertoast.showToast(
        msg: 'Password reset failed. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again later.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // show an account deletition dialog
  void showDeleteDialog() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: emailTextController.text, // Replace with the user's password
      );
      await currentUser.reauthenticateWithCredential(credential);

      // Delete the user's data from Firestore
      final userDocs = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: currentUser.email)
          .get();

      final postDocs = await FirebaseFirestore.instance
          .collection("Posts")
          .where("UserEmail", isEqualTo: currentUser.email)
          .get();

      final chatDocs = await FirebaseFirestore.instance
          .collection("Chat")
          .where("UserEmail", isEqualTo: currentUser.email)
          .get();

      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }
      for (var doc in postDocs.docs) {
        await doc.reference.delete();
      }
      for (var doc in chatDocs.docs) {
        await doc.reference.delete();
      }

      // Delete the user account from Firebase Auth
      await currentUser.delete();

      // Dismiss the dialog
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.code,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // navigate to home page
  void goToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          56.0,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: AppBar(
              title: GestureDetector(
                onTap: () {
                  // Call your function here
                  goToHomePage();
                },
                child: Text(
                  "D E L E T E  A C C O U N T",
                  selectionColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              centerTitle: true,

              elevation: 0.0,
              // backgroundColor: Colors.black.withOpacity(0.2),
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.2),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              // const SizedBox(height: 25),
              /*Icon(
                      Icons.person,
                      size: 72,
                    ),*/
              const SizedBox(height: 20),

              MyTextField(
                controller: emailTextController,
                hintText: 'Enter your password',
                obscureText: true,
                maxLength: 0,
                isText: true,
              ),

              SizedBox(
                width: double
                    .infinity, // Make sure the container is as wide as its parent
                child: GestureDetector(
                  onTap: showDeleteDialog,
                  child: SizedBox(
                    width: 60, // Adjust the width as needed
                    height: 50,
                    child: Container(
                      padding:
                          EdgeInsets.all(10), // Reduce padding to fit the text

                      child: Center(
                        child: Text(
                          "Delete account",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "All your data will be deleted within 31 days",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
