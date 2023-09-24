// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages,

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexus/pages/admin_chat.dart';
import 'package:nexus/pages/home_page.dart';

class FullScreenImg extends StatefulWidget {
  final String photoUrl;
  final String message;
  final String username;
  final String timeStamp;
  const FullScreenImg({
    Key? key,
    required this.photoUrl,
    required this.message,
    required this.username,
    required this.timeStamp,
  }) : super(key: key);

  @override
  State<FullScreenImg> createState() => _FullScreenImgState();
}

class _FullScreenImgState extends State<FullScreenImg> {
  // Add a GlobalKey for the Scaffold to access the ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  //sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToAdminChatPage() {
    // Navigate to the admin chat page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatPage(),
      ),
    );
  }

  void goToHomePage() {
    // Navigate to the admin chat page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            goToHomePage(); // Add parentheses to call the function
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(widget.photoUrl),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Column(
              mainAxisAlignment: MainAxisAlignment.end, // Align at the bottom
              children: [
                if (widget.photoUrl != "") const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      widget.username, // Use the correct variable name
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      "  ",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      widget.timeStamp, // Use the correct variable name
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
