// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/pages/home_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
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
      editField("password");
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

  Future<void> editField(String field) async {
    var userCollection = FirebaseFirestore.instance.collection('users');
    var userQuery = userCollection.where('email', isEqualTo: currentUser.email);

    var querySnapshot = await userQuery.get();

    if (querySnapshot.size > 0) {
      var userDocument = querySnapshot.docs[0];

      updatedValue =
          userDocument[field]; // Initialize updatedValue with the current value

      String? newValue = emailTextController.text;

      // ignore: unnecessary_null_comparison
      if (newValue != null && newValue.trim().isNotEmpty) {
        await userDocument.reference.update({field: newValue});
        setState(() {
          username = newValue;
        });
      }
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
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: currentUser.email)
        .get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                  "P A S S W O R D  R E S E T",
                  selectionColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              centerTitle: true,

              elevation: 0.0,
              // backgroundColor: Colors.black.withOpacity(0.2),
              backgroundColor:
                  Theme.of(context).colorScheme.background.withOpacity(0.2),
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: docRef,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.size == 0) {
              return Center(child: Text('No matching user found.'));
            }

            var userDocument = snapshot.data!.docs[0];
            username = userDocument['username'];
            address = userDocument['address'];
            website = userDocument['website'];
            admin = userDocument['admin'];

            return Center(
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
                      hintText: 'Your email',
                      obscureText: true,
                    ),

                    SizedBox(
                      width: double
                          .infinity, // Make sure the container is as wide as its parent
                      child: GestureDetector(
                        onTap: change_password,
                        child: SizedBox(
                          width: 60, // Adjust the width as needed
                          height: 50,
                          child: Container(
                            padding: EdgeInsets.all(
                                10), // Reduce padding to fit the text

                            child: Center(
                              child: Text(
                                "Send reset email",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
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
                          "Sorry that password won't work, you must include: a symbol, a number, a hieroglyph, a gang sign, an inspiring quote, a poem that you just wrote, a picture of your favorite animal made using only characters on your keyboard, and an uppercase letter.",
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
            );
          }),
    );
  }
}
