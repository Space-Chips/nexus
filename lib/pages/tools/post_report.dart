// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, avoid_print, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/profile_page.dart';

class PostReport extends StatefulWidget {
  final String reporter;
  final String reported;
  final String detail;
  final String postId;
  final String reportedPostId;

  //final List<String> comments;
  const PostReport({
    super.key,
    required this.reporter,
    required this.reported,
    required this.detail,
    required this.postId,
    required this.reportedPostId,
  });

  @override
  State<PostReport> createState() => _PostReportState();
}

class _PostReportState extends State<PostReport> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isBlocked = false;
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
// Add a flag to check if the widget is disposed
  bool isCommentDialogOpen = false;
  int commentNumber = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    addView();
    getCommentNumber();

    //fetchIdData();
  }

  @override
  void dispose() {
// Set the flag when the widget is disposed
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

  // send a report message
  void showContextDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("C O N T E X T"),
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

                FirebaseFirestore.instance
                    .collection("Reports")
                    .doc(widget.postId)
                    .delete();

                // dismiss the dialog
//                Navigator.pop(context);
              },
              child: const Text("D E L E T E"))
        ],
      ),
    );
  }

  // delete a post
  void acceptReport() {
    // show a dialog box asking for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("A G R E E  R E P O R T"),
        content: const Text(
          "Are you sure you want to ruin this person's day?",
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
                      .doc(widget.reportedPostId)
                      .collection("Comments")
                      .doc(doc.id)
                      .delete();
                }
                final userDataQuery = await FirebaseFirestore.instance
                    .collection("users")
                    .where('email', isEqualTo: widget.reporter)
                    .get();

                if (userDataQuery.docs.isNotEmpty) {
                  final userDataDoc = userDataQuery.docs[0];
                  final confirmedReports = userDataDoc['confirmedReports'] + 1;

                  // Get the document reference and update the field
                  final userDocRef = FirebaseFirestore.instance
                      .collection("users")
                      .doc(userDataDoc.id);
                  await userDocRef
                      .update({'confirmedReports': confirmedReports + 1});
                }

                // then delete the Post
                FirebaseFirestore.instance
                    .collection("Posts")
                    .doc(widget.reportedPostId)
                    .delete();

                FirebaseFirestore.instance
                    .collection("Reports")
                    .doc(widget.postId)
                    .delete();

                // dismiss the dialog
                Navigator.pop(context);
              },
              child: const Text("D I E"))
        ],
      ),
    );
  }

  // delete a post
  void declineReport() {
    // show a dialog box asking for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("D E C L I N E  R E P O R T"),
        content: const Text(
          "Are you sure you want to decline this report ?",
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

                // Delete report
                FirebaseFirestore.instance
                    .collection("Reports")
                    .doc(widget.postId)
                    .delete();

                // dismiss the dialog
                Navigator.pop(context);
              },
              child: const Text("D E C L I N E"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  widget.detail,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[700]!,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  )
                ],
              ),
              margin: EdgeInsets.only(top: 25, left: 25, right: 25),
              //padding: EdgeInsets.all(5),
              child: Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Posts')
                      .doc(widget.reportedPostId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final postDocument = snapshot.data!;
                      print(widget.reportedPostId);
                      final postData = postDocument.data();

                      if (postData != null) {
                        return WallPost(
                          message: postData['Message'],
                          user: postData['User'],
                          userEmail: postData['UserEmail'],
                          isAdminPost: postData['isAdminPost'],
                          mediaDest: postData['MediaDestination'],
                          contextText: postData['Context'],
                          postId: postDocument.id,
                          likes: List<String>.from(postData['Likes'] ?? []),
                          views: List<String>.from(postData['Views'] ?? []),
                          time: formatDate(postData['TimeStamp']),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "reporter : ",
                          // usernamestate
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            goToProfilePage(widget.reporter);
                          },
                          child: Text(
                            widget.reporter,
                            // usernamestate
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "  ",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Row(
                      children: [
                        Text(
                          "reported : ",
                          // usernamestate
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            goToProfilePage(widget.reported);
                          },
                          child: Text(
                            widget.reported,
                            // usernamestate
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // Display the menue
                PopupMenuButton(
                  color: Colors.white,
                  icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: 'Comming soon',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.developer_board, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            "Comming soon",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (index) async {
                    switch (index) {
                      case 'Comming soon':
                        break;
                    }
                  },
                )
              ],
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    acceptReport();
                  },
                  child: Row(
                    children: const [
                      Text(
                        "Approve",
                        // usernamestate
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.check_rounded)
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    declineReport();
                  },
                  child: Row(
                    children: const [
                      Text(
                        "Disaprove",
                        // usernamestate
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.block)
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
