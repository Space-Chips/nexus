// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexus/pages/home_page.dart';
import 'package:nexus/pages/settings/accesibility_language_display/display_settings.dart';
import 'package:nexus/pages/settings/your-account/change_password.dart';
import 'package:nexus/theme/dark_theme.dart';
import 'package:nexus/theme/light_theme.dart';
import 'package:settings_ui/settings_ui.dart';

class LanguageEct extends StatefulWidget {
  const LanguageEct({super.key});

  @override
  State<LanguageEct> createState() => _LanguageEctState();
}

class _LanguageEctState extends State<LanguageEct> {
  late String username;
  late String address;
  late String website;
  late String updatedValue; // Declare updatedValue as a class-level variable
  late bool admin;

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool showPosts = true;
  bool isFollowing = false;
  bool isSwitched = false;

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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            goToHomePage();
          },
          child: Text(
            "Y O U R  A C C O U N T",
            selectionColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SettingsList(
        lightTheme: lightSettingsTheme,
        darkTheme: darkSettingsTheme,
        sections: [
          SettingsSection(
            // title: Text("Section 1"),
            tiles: [
              // Your displayer
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.pencil),
                title: Text('Display'),
                description:
                    Text('Manage your font size, color, and background.'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplaySettings(),
                    ),
                  );
                },
              ),
              // Your displayer
              SettingsTile.navigation(
                leading: Icon(Icons.language_outlined),
                title: Text('Languages'),
                description: Text('C O M I N G  S O O N'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordPage()),
                  );
                },
              ),
              // Your displayer
              SettingsTile(
                title: Text('Delete your account data'),
                description: Text('Find out how to deactivate your account.'),
                leading: Icon(CupertinoIcons.delete),
                onPressed: (context) {
                  showDeleteDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
