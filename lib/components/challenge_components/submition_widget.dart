// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, avoid_print, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/components/delete_button.dart';
import 'package:nexus/pages/full_image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexus/pages/profile_page.dart';

import '../like_button.dart';

class SubmitionWidget extends StatefulWidget {
  final String message;
  final String user;
  final String userEmail;
  final String time;
  final String postId;
  final String mediaDest;
  final String contextText;
  final String category;
  final bool isAdminPost;
  final List<String> likes;
  final List<String> views;
  //final List<String> comments;
  const SubmitionWidget({
    super.key,
    required this.message,
    required this.category,
    required this.user,
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
  State<SubmitionWidget> createState() => _SubmitionWidgetState();
}

class _SubmitionWidgetState extends State<SubmitionWidget> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";
  String postUsername = "Test Username";
  String currentDocumentId = "";
  final commentTextController = TextEditingController();
  final reportTextController = TextEditingController();
  var commentTextcontrollerstring = "";
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
    getId();
    getCommentNumber();
    //fetchIdData();
    if (widget.mediaDest.isNotEmpty) {
      getMediaUrl();
    }
    addView();

    isLiked = widget.likes.contains(currentUser.email);
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag when the widget is disposed
    super.dispose();
    addView();
    getId();
  }

  void getId() async {
    addView();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Challenge")
        .where("name", isEqualTo: widget.category)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Loop through the query results
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String documentId = doc.id;
        setState(() {
          currentDocumentId = documentId;
        });
      }
    }
  }

  Future<void> getCommentNumber() async {
    var docs = await FirebaseFirestore.instance
        .collection('Challenge')
        .doc(widget.category)
        .collection('Submitions')
        .doc(widget.postId)
        .collection("Comments")
        .get();
    final int count = docs.size;
    setState(() {
      commentNumber = count;
    });
  }

  Future<void> getMediaUrl() async {
    final ref = storage.ref().child("files/${widget.mediaDest}");

    try {
      final url = await ref.getDownloadURL();

      // Check if the widget is still active before calling setState
      if (!_isDisposed) {
        setState(() {
          mediaUrl = url;
        });
      }
    } catch (e) {
      // Handle error
    }
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

  // Add the user email to the view map
  void addView() async {
    // Access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("Challenge")
        .doc(currentDocumentId)
        .collection("Submitions")
        .doc(widget.postId);

    // If the post is now liked, add the user's email to the 'Likes' field
    postRef.update({
      'Views': FieldValue.arrayUnion([currentUser.email])
    }).catchError((error) {
      print("Error adding like: $error");
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
          username: username,
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
  void toggleLike() async {
    HapticFeedback.lightImpact();

    setState(() {
      isLiked = !isLiked;
    });

    // Access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection("Challenge")
        .doc(currentDocumentId)
        .collection("Submitions")
        .doc(widget.postId);

    if (isLiked) {
      // If the post is now liked, add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      }).catchError((error) {
        print("Error adding like: $error");
      });
    } else {
      // If the post is unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      }).catchError((error) {
        print("Error removing like: $error");
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('Challenge')
        .doc(widget.category)
        .collection('Submitions')
        .doc(widget.postId);

    postRef.update({
      'CommentNumber': FieldValue.arrayUnion([currentUser.email]),
    });

    // write the comment  to firestore under the comments
    FirebaseFirestore.instance
        .collection('Challenge')
        .doc(widget.category)
        .collection('Submitions')
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

  // post context
  void postContext(String text) {
    // store in firebase

    FirebaseFirestore.instance
        .collection('Challenge')
        .doc(widget.category)
        .collection('Submitions')
        .doc(widget.postId)
        .update({
      'Context': text,
    });
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

  // send a report message
  void showContextDialog() {
    HapticFeedback.lightImpact();

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
    HapticFeedback.lightImpact();

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
                /*final commentDocs = await FirebaseFirestore.instance
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
                }*/

                // then delete the Post
                FirebaseFirestore.instance
                    .collection("Challenge")
                    .doc(currentDocumentId)
                    .collection("Submitions")
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

  void openFullScreenPage() {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImg(
          photoUrl: mediaUrl,
          message: widget.message,
          username: widget.user,
          timeStamp: widget.time,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    addView();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mediaDest != "")
            Center(
              child: GestureDetector(
                onTap: () {
                  openFullScreenPage();
                },
                child: SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: mediaUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (widget.mediaDest != "") const SizedBox(height: 20),
          if (widget.mediaDest == "") const SizedBox(height: 5),

          Text(widget.message),

          // Wall post
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
                      GestureDetector(
                        onTap: () {
                          goToProfilePage(widget.user);
                        },
                        child: Text(
                          widget.user,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
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
                        color: Colors.white,
                        icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        itemBuilder: (_) => <PopupMenuItem<String>>[
                          PopupMenuItem<String>(
                            value: 'report',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.flag_outlined, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  "Report",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          if (isAdminState == true)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete_outlined,
                                      color: Colors.black),
                                  SizedBox(width: 5),
                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          if (isAdminState == true)
                            PopupMenuItem<String>(
                              value: 'add_context',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.group, color: Colors.black),
                                  SizedBox(width: 5),
                                  Text(
                                    "Note",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (index) async {
                          switch (index) {
                            case 'report':
                              showReportDialog();
                              break;
                            case 'add_context':
                              showContextDialog();
                              break;
                            case 'delete':
                              deletePost();
                              break;
                          }
                        },
                      )
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
              Row(
                children: [
                  // Like Button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  const SizedBox(width: 10),

                  // like count
                  Text(widget.likes.length.toString(),
                      style: TextStyle(color: Colors.grey)),

                  // Like Count
                ],
              ),
              const SizedBox(width: 20),

              // VIEW COUNT
              Row(
                children: [
                  // Like Button
                  Icon(Icons.bar_chart_rounded, color: Colors.grey[500]),

                  SizedBox(width: 10),

                  // view count
                  Text(widget.views.length.toString(),
                      style: TextStyle(color: Colors.grey)),

                  // Like Count
                ],
              ),

              const SizedBox(width: 20),

              // delete button

              if (widget.user == usernameState) DeleteButton(onTap: deletePost)
            ],
          ),
        ],
      ),
    );
  }
}
