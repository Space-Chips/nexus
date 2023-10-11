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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToAdminChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatPage(),
      ),
    );
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

  void goToHomePage() {
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
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            goToHomePage();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share, // Add a share button
              color: Colors.white,
            ),
            onPressed: () {
              displayMessage("Coming Soon");
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.photoUrl,
                  loadingBuilder: (context, child, progress) {
                    if (progress != null) {
                      return CircularProgressIndicator();
                    }
                    if (child == null) {
                      return Text(
                        'Failed to load image', // Handle image loading error
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    }
                    return child;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.username} • ${widget.timeStamp}',
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
