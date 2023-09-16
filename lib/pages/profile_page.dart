// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/editable_text_box.dart';
import 'package:nexus/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({
    super.key,
    required this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;
  late String updatedValue; // Declare updatedValue as a class-level variable

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

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: widget.username)
        .get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("P R O F I L E  P A G E"),
        elevation: 0,
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

            return ListView(
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 50),
                Text(
                  widget.username,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                MyTextBox(
                  text: username, // Now you can use the username variable here
                  sectionName: 'username',
                ),
                MyTextBox(
                  text: userDocument['bio'],
                  sectionName: 'bio',
                ),
                const SizedBox(height: 50),

                //Padding(
                //  padding: const EdgeInsets.only(left: 25.0),
                //  child: Text(
                //    'My posts',
                //    style: TextStyle(
                //      color: Colors.grey[600],
                //    ),
                //  ),
                //),
              ],
            );
          }),
    );
  }
}
