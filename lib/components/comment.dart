import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  final String text;
  final String user;
  final String time;
  final String postId;
  final String commentId;
  final String usernameState;

  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.postId,
    required this.commentId,
    required this.usernameState,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";
  String postUsername = "Test Username";
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Call this function in initState
    addView();
  }

  // Add the user email to the view map
  void addView() {
    // Acces the document is Firebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postId)
        .collection("Comments")
        .doc(widget.commentId);

    postRef.update({
      'Views': FieldValue.arrayUnion([currentUser.email])
    });
  }

  // Fetch user data from Firebase
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var username = userData['username'];
      var isAdmin = userData['admin'];
      var email = userData['email'];

      setState(() {
        usernameState = username;
        isAdminState = isAdmin; // Assuming you have an 'isAdminState' variable
        userEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(7),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // comment
          Text(widget.text),

          const SizedBox(height: 5),

          // user, time
          Row(
            children: [
              Text(
                widget.usernameState,
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                "  ",
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}
