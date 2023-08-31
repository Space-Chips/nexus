// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/comment.dart';
import 'package:nexus/components/comment_button.dart';
import 'package:nexus/components/delet_button.dart';
import 'package:nexus/helper/helper_methods.dart';

import 'like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String userEmail;
  final String time;
  final String postId;
  final bool isAdminPost;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    required this.userEmail,
    required this.isAdminPost,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";

  // comment text controller
  final commentTextController = TextEditingController();
  final reportTextController = TextEditingController();
  var commentTextcontrollerstring = "";

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    fetchUserData();
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

  // add a comment
  void addComment(String commentText) {
    // write the comment  to firestore under the comments
    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": usernameState,
      "CommentTime": Timestamp.now(), // remember to format this when displaying
      "CommentedByEmail": userEmail,
    });
  }

  // post message
  void postReport(String postText) {
    // store in firebase
    FirebaseFirestore.instance.collection("Admin_Chat").add(
      {
        'User': usernameState,
        'UserEmail': currentUser.email,
        'Message': postText,
        'TimeStamp': Timestamp.now(),
        'isAdminPost': isAdminState,
        'Likes': [],
      },
    );
  }

  // show a dialog box for adding a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("A D D  C O M E N T"),
        content: TextField(
          controller: commentTextController,
          decoration: InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          // save button
          TextButton(
            onPressed: () {
              if (commentTextController.text.isNotEmpty) {
                // add coment
                addComment(commentTextController.text);
                // pop box
                commentTextController.clear();
                Navigator.pop(context);
              } else {
                // pop box
                commentTextController.clear();
                Navigator.pop(context);
              }
            },
            child: Text("P O S T"),
          ),

          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "C A N C E L",
              selectionColor: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  // send a report message
  void showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("R E P O R T"),
        content: TextField(
          controller: reportTextController,
          decoration: InputDecoration(hintText: "Add details..."),
        ),
        actions: [
          // save button
          TextButton(
            onPressed: () {
              if (reportTextController.text.isNotEmpty) {
                // add coment
                postReport(
                    "⚠️REPORT⚠️ $userEmail just reported a post !! It reports ${widget.userEmail}, he says that ${reportTextController.text} / the post id is ${widget.postId} ");
                // pop box
                reportTextController.clear();
                Navigator.pop(context);
              } else {
                // pop box
                commentTextController.clear();
                Navigator.pop(context);
              }
            },
            child: Text("S E N D"),
          ),

          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "C A N C E L",
              selectionColor: Colors.blue,
            ),
          )
        ],
      ),
    );
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
                // delete the comments from firesotre first
                // (if you only delete the post, the comments will still  be stored in firestore)
                final commentDocs = await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(widget.postId)
                    .collection("Comments")
                    .get();

                for (var doc in commentDocs.docs) {
                  await FirebaseFirestore.instance
                      .collection("Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .doc(doc.id)
                      .delete();
                }

                // then delete the Post
                FirebaseFirestore.instance
                    .collection("Posts")
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
          Text(widget.message),

          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text (message + user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // message

                  const SizedBox(height: 5),

                  // user
                  Row(
                    children: [
                      Text(
                        widget.user,
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

                      // Display the Admin Badge
                      if (widget.isAdminPost == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ),

                      // Display the menue
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert,
                            color: Colors.grey[500]), // add this line
                        itemBuilder: (_) => <PopupMenuItem<String>>[
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: SizedBox(
                              width: 100,
                              // height: 30,

                              child: Text(
                                "Report",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          if (isAdminState == true)
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: SizedBox(
                                width: 100,
                                // height: 30,
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                        ],
                        onSelected: (index) async {
                          switch (index) {
                            case 'report':
                              showReportDialog();
                              break;
                            case 'delete':
                              deletePost();
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LIKE
              Column(
                children: [
                  // Like Button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  const SizedBox(height: 5),

                  // like count
                  Text(widget.likes.length.toString(),
                      style: TextStyle(color: Colors.grey)),

                  // Like Count
                ],
              ),
              const SizedBox(width: 20),

              // COMMENT
              Column(
                children: [
                  // Like Button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),

                  const SizedBox(height: 5),

                  // like count
                  Text(('0'), style: TextStyle(color: Colors.grey)),

                  // Like Count
                ],
              ),
              const SizedBox(width: 20),
              // delete button

              if (widget.user == usernameState) DeleteButton(onTap: deletePost)
            ],
          ),

          const SizedBox(height: 20),

          // comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // show loading cirlce if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                );
              }

              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  // return the comment
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    usernameState: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
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
    );
  }
}
