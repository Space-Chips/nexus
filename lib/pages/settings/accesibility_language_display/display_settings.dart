// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/editable_text_box.dart';
import 'package:nexus/components/text_box.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/home_page.dart';

class DisplaySettings extends StatefulWidget {
  const DisplaySettings({super.key});

  @override
  State<DisplaySettings> createState() => _DisplaySettingsState();
}

class _DisplaySettingsState extends State<DisplaySettings> {
  late String username;
  late String address;
  late String website;
  late String updatedValue; // Declare updatedValue as a class-level variable
  late bool admin;

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

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

  // show an account deletition dialog
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("DELETE YOUR ACCOUNT & DATA"),
        actions: [
          // "Yes" button
          TextButton(
            onPressed: () async {
              // Delete the user's data from Firestore
              final userDocs = await FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: currentUser.email)
                  .get();

              for (var doc in userDocs.docs) {
                await doc.reference.delete();
              }

              // Delete the user account from Firebase Auth
              await currentUser.delete();

              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text("Y E S"),
          ),

          // "Cancel" button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("C A N C E L"),
          )
        ],
      ),
    );
  }

  Future<void> editField(String field) async {
    var userCollection = FirebaseFirestore.instance.collection('users');
    var userQuery = userCollection.where('email', isEqualTo: currentUser.email);

    var querySnapshot = await userQuery.get();

    if (querySnapshot.size > 0) {
      var userDocument = querySnapshot.docs[0];

      updatedValue =
          userDocument[field]; // Initialize updatedValue with the current value

      String? newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.length > 2) {
                      updatedValue = value; // Update the updatedValue variable
                    } else {
                      // pop box
                    }
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                if (updatedValue.length > 2) {
                  // add coment
                  Navigator.of(context).pop(updatedValue);
                  // pop box
                } else {
                  // pop box
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

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
                  "D I S P L A Y  S E T T I N G S",
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

            return ListView(
              children: [
                // const SizedBox(height: 25),
                /*Icon(
                  Icons.person,
                  size: 72,
                ),*/

                GestureDetector(
                  onTap: () {
                    AdaptiveTheme.of(context).toggleThemeMode();
                    setState(() {}); // Trigger a rebuild after theme change
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 20,
                    ),
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bedtime_outlined),
                            SizedBox(width: 14),
                            Text(
                              "Toggle Theme",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // SizedBox(height: 14),
                  ),
                ),
                MyEditableTextBox(
                  text: userDocument['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField("bio"),
                ),
                MyEditableTextBox(
                  text: userDocument['address'],
                  sectionName: 'address',
                  onPressed: () => editField("address"),
                ),

                MyEditableTextBox(
                  text: userDocument['website'],
                  sectionName: 'your website',
                  onPressed: () => editField("website"),
                ),

                MyTextBox(
                  text: formatDate(userDocument['joinDate']),
                  sectionName: 'joinDate',
                ),

                MyTextBox(
                  text: 'Coming Soon',
                  sectionName: 'birth date',
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
                        padding: EdgeInsets.all(
                            10), // Reduce padding to fit the text

                        child: Center(
                          child: Text(
                            "Delete your account data",
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
                const SizedBox(height: 10),
              ],
            );
          }),
    );
  }
}
