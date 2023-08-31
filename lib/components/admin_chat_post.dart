// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminChatPosts extends StatefulWidget {
  final String message;
  final String user;
  final String userEmail;
  final String time;
  final String postId;
  final List<String> likes;
  const AdminChatPosts({
    super.key,
    required this.message,
    required this.user,
    required this.userEmail,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<AdminChatPosts> createState() => _AdminChatPostsState();
}

class _AdminChatPostsState extends State<AdminChatPosts> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";

  // comment text control

  @override
  void initState() {
    super.initState();
    fetchUserData();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // Fetch user data from Firebase
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email",
            isEqualTo: currentUser.email) // Use the current user's email
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Check if any documents match the query
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var username = userData['username'];
      var isAdmin = userData['admin'];
      var email = userData['email'];

      setState(() {
        // Update isAdmin and username in the state
        usernameState = username;
        isAdminState = isAdmin;
        userEmail = email;
      });
    } else {
      //print("User data not found");
    }
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Acces the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, and the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // delete a post
  void deletePost() {
    // show a dialog box asking for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("D E L E T E  P O S T"),
        content: const Text(
          "Are you sure you want to delete this post ???",
          selectionColor: Colors.blue,
        ),
        actions: [
          // CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "C A N C E L",
              selectionColor: Colors.blue,
            ),
          ),

          // DELETE BUTTON
          TextButton(
              onPressed: () async {
                // then delete the Post
                FirebaseFirestore.instance
                    .collection("Chat")
                    .doc(widget.postId)
                    .delete();
                // dismiss the dialog
                Navigator.pop(context);
              },
              child: const Text("D E L E T E"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AdminChatPosts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // message
              Text(widget.message),

              const SizedBox(height: 5),

              // user
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    " . ",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
              // Display the User Email for admins
              //if (isAdminState == true)
              //  Text(
              //    widget.userEmail, // Display the username here
              //   style: TextStyle(
              //      color: Colors.grey[400],
              //      fontSize: 16, // Set an appropriate font size
              //      fontWeight: FontWeight.bold, // You can adjust the style
              //    ),
              //  ),
            ],
          ),
        ],
      ),
    );
  }
}
