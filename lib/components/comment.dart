import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Comment extends StatefulWidget {
  final String text;
  final String user;
  final String time;
  final String email;
  final String postId;
  final String commentId;
  final String usernameState;
  final bool isAdmin;

  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.email,
    required this.postId,
    required this.commentId,
    required this.usernameState,
    required this.isAdmin,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "[Deleted]";
  String userEmail = "[Deleted]";
  String postUsername = "[Deleted]";
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
              HapticFeedback.heavyImpact();

              // Delete the current comment
              await FirebaseFirestore.instance
                  .collection("Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .doc(widget.commentId)
                  .delete();

              // dismiss the dialog
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text("D E L E T E"),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: widget.isAdmin == true || widget.email == currentUser.email
            ? Slidable(
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: ((context) {
                        // delete post
                        deletePost();
                      }),
                      icon: Icons.delete,
                      label: 'Delete',
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
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
                ),
              )
            : Container(
                // Non-admin version of the widget
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
              ),
      ),
    );
  }
}
