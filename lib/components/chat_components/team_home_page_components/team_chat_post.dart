// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, avoid_print, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/components/comment.dart';
import 'package:nexus/components/comment_button.dart';
import 'package:nexus/components/community_notes.dart';
import 'package:nexus/components/delete_button.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/full_image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexus/pages/profile_page.dart';
import '../../like_button.dart';

class TeamChatPost extends StatefulWidget {
  final String message;
  final String userEmail;
  final Timestamp time;
  final String postId;
  final String mediaDest;
  final String contextText;
  final bool isAdminPost;
  final List<String> likes;
  final List<String> views;
  //final List<String> comments;
  const TeamChatPost({
    super.key,
    required this.message,
    required this.postId,
    required this.likes,
    required this.views,
    required this.contextText,
    //required this.comments,
    required this.time,
    required this.userEmail,
    required this.isAdminPost,
    required this.mediaDest,
  });

  @override
  State<TeamChatPost> createState() => _TeamChatPostState();
}

class _TeamChatPostState extends State<TeamChatPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isBlocked = false;
  bool isRight = false;
  bool isAdminState = false;
  String usernameState = "[Deleted]";
  String userEmail = "[Deleted]";
  String postUsername = "[Deleted]";
  final commentTextController = TextEditingController();
  final reportTextController = TextEditingController();
  var commentTextcontrollerstring = "";
  var blockedUsersEmails = [];
  var commentdata;
  late String mediaUrl = ""; // Initialize mediaUrl with an empty string
  final storage = FirebaseStorage.instance;
  bool _isDisposed = false; // Add a flag to check if the widget is disposed
  bool isCommentDialogOpen = false;
  int commentNumber = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    addView();
    getCommentNumber();
    fetchPostUsername();
    //fetchIdData();

    isLiked = widget.likes.contains(currentUser.email);

    if (widget.userEmail == currentUser.email) {
      isRight = true;
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag when the widget is disposed
    super.dispose();
  }

  Future<void> getCommentNumber() async {
    var docs = await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments')
        .get();
    final int count = docs.size;
    setState(() {
      commentNumber = count;
    });
  }

  // Fetch user data from Firebase
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Check if any documents match the query
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var blockedUsers = userData['blockedUsersEmails'];
      var username = userData['username'];
      var isAdmin = userData['admin'];
      var email = userData['email'];

      setState(() {
        // Update isAdmin and username in the state
        blockedUsersEmails = blockedUsers;
        usernameState = username;
        isAdminState = isAdmin;
        userEmail = email;

        if (blockedUsersEmails.contains(userEmail)) {
          isBlocked = true;
        }
      });
    } else {
      //print("User data not found");
    }
  }

  // Fetch user data from Firebase
  void fetchPostUsername() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: widget.userEmail)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Check if any documents match the query
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;

      var username = userData['username'];

      setState(() {
        // Update isAdmin and username in the state
        postUsername = username;
      });
    } else {
      //print("User data not found");
    }
  }

  // Add the user email to the view map
  void addView() {
    // Acces the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Posts').doc(widget.postId);

    postRef.update({
      'Views': FieldValue.arrayUnion([currentUser.email])
    });
  }

  // navigate to profile page
  void goToProfilePage(String username) {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          email: username,
        ),
      ),
    );
  }

  // Fetch user data from Firebase
  /*void fetchIdData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("userId", isEqualTo: widget.userId)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Check if any documents match the query
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var username = userData['username'];
      var isAdmin = userData['admin'];

      setState(() {
        // Update isAdmin and username in the state
        isAdminState = isAdmin;
        postUsername = username;
      });
    } else {
      //print("User data not found");
    }
  }*/

  // toggle like
  void blockUser() {
    HapticFeedback.mediumImpact();
    setState(() {
      isBlocked = !isBlocked;
    });

    // Access the document in Firebase
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    Query query = usersRef.where("email", isEqualTo: currentUser.email);

    query.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // Get the specific DocumentReference
        DocumentReference documentRef = doc.reference;

        if (isBlocked) {
          // If the user is being blocked, add their email to the 'blockedUsersEmails' array
          documentRef.update({
            'blockedUsersEmails': FieldValue.arrayUnion([widget.userEmail])
          });
        } else {
          // If the user is being unblocked, remove their email from the 'blockedUsersEmails' array
          documentRef.update({
            'blockedUsersEmails': FieldValue.arrayRemove([widget.userEmail])
          });
        }
      }
    });
  }

  // toggle like
  void toggleLike() {
    HapticFeedback.mediumImpact();
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
    HapticFeedback.lightImpact();

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Posts').doc(widget.postId);

    postRef.update({
      'CommentNumber': FieldValue.arrayUnion([currentUser.email]),
    });

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

  // post report
  void postReport(String postText) {
    HapticFeedback.lightImpact();

    // store in firebase

    FirebaseFirestore.instance.collection("Reports").add(
      {
        'Reporter': userEmail,
        'Reported': widget.userEmail,
        'Detail': postText,
        'PostId': widget.postId,
        'Timestamp': FieldValue.serverTimestamp(),
      },
    );
  }

  // post context
  void postContext(String text) {
    HapticFeedback.lightImpact();

    // store in firebase

    FirebaseFirestore.instance.collection("Posts").doc(widget.postId).update({
      'Context': text,
    });
  }

  // show comments
  void showComments() {
    HapticFeedback.lightImpact();

    if (isCommentDialogOpen == true) {
      setState(() {
        isCommentDialogOpen = false;
      });
    } else {
      setState(() {
        isCommentDialogOpen = true;
      });
    }
  }

  // post comment method
  void postComment() {
    HapticFeedback.mediumImpact();

    if (commentTextController.text.isNotEmpty) {
      // add comment
      addComment(commentTextController.text);
      // pop box
      commentTextController.clear();
    }
  }

  // show a dialog box for adding a comment
  void showCommentDialog() {
    HapticFeedback.lightImpact();

    if (isCommentDialogOpen == true) {
      setState(() {
        isCommentDialogOpen = false;
      });
    } else {
      setState(() {
        isCommentDialogOpen = true;
      });
    }

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

// Send a report message
  void showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withOpacity(1), // Adjust opacity for the frosted effect
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reportTextController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: "Add details (limit: 50 characters)...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (reportTextController.text.isNotEmpty) {
                          postReport(reportTextController.text);
                          reportTextController.clear();
                          Navigator.pop(context);
                        } else {
                          // Display an error message or handle accordingly
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .tertiary, // Adjust button color
                      ),
                      child: Text(
                        "S E N D",
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "C A N C E L",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ), // Adjust button color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Add context to a post
  void showContextDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withOpacity(1), // Adjust opacity for the frosted effect
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reportTextController,
                  decoration: InputDecoration(
                    hintText: "Add details here...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (reportTextController.text.isNotEmpty) {
                          // add coment
                          postContext(reportTextController.text);
                          // pop box
                          reportTextController.clear();
                          Navigator.pop(context);
                        } else {
                          // pop box
                          commentTextController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .tertiary, // Adjust button color
                      ),
                      child: Text(
                        "S E N D",
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "C A N C E L",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ), // Adjust button color
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Remember, community notes have no delete button. Proceed with caution",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // delete a post
  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withOpacity(1), // Adjust opacity for the frosted effect
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  "ARE YOU SURE YOU WANT TO DELETE THIS POST ?",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // DELETE BUTTON
                    ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.heavyImpact();

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .tertiary, // Adjust button color
                      ),
                      child: Text(
                        "D E L E T E",
                      ),
                    ),

                    // CANCEL BUTTON
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "C A N C E L",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ), // Adjust button color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openFullScreenPage() {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImg(
          photoUrl: mediaUrl,
          message: widget.message,
          username: postUsername,
          timeStamp: formatDate(widget.time),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messageColor = isRight
        ? colorScheme.primary.withOpacity(1)
        : colorScheme.secondary.withOpacity(0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // Message Container

          Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: messageColor,
                  /*boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],*/
                ),
                child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isRight) _buildAvatar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: isRight
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // Message Text
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                // Metadata Row
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: isRight
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      postUsername,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatDate(widget.time),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (widget.isAdminPost) ...[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          Icons.shield_outlined,
                                          size: 15,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                    if (isRight) ...[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          CupertinoIcons.create_solid,
                                          size: 15,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isRight) _buildAvatar(),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: const Icon(
            Icons.person,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
