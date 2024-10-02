// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, avoid_print, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String userEmail;
  final String time;
  final String postId;
  final String mediaDest;
  final String contextText;
  final bool isAdminPost;
  final List<String> likes;
  final List<String> views;
  //final List<String> comments;
  const WallPost({
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
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
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
    if (widget.mediaDest.isNotEmpty) {
      getMediaUrl();
    }
    isLiked = widget.likes.contains(currentUser.email);
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

  Future<void> getMediaUrl() async {
    final ref =
        FirebaseStorage.instance.ref().child("files/${widget.mediaDest}");

    try {
      final url = await ref.getDownloadURL();
      if (!_isDisposed) {
        setState(() {
          mediaUrl = url;
        });
      }
    } catch (e) {
      // Handle error
      if (!_isDisposed) {
        setState(() {
          mediaUrl = ""; // Or a default/error image URL
        });
      }
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
          timeStamp: widget.time,
        ),
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mediaDest != "")
            Center(
              child: GestureDetector(
                onTap: () {
                  openFullScreenPage();
                  print(widget.mediaDest);
                },
                child: SizedBox(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        key: ValueKey(widget.postId),
                        imageUrl: mediaUrl,
                        placeholder: (context, url) => SizedBox(
                          width: 300, // Adjust as needed
                          height: 200, // Adjust as needed
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        fadeInDuration: Duration(milliseconds: 300),
                        errorWidget: (context, url, error) => Container(
                          width: 300, // Adjust as needed
                          height: 200, // Adjust as needed
                          color: Theme.of(context).colorScheme.secondary,
                          child: Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 35,
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ),

          if (widget.mediaDest != "") const SizedBox(height: 20),
          if (widget.mediaDest == "") const SizedBox(height: 5),

          SelectableText(widget.message),

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
                          HapticFeedback.mediumImpact();
                          goToProfilePage(widget.userEmail);
                        },
                        child: Text(
                          postUsername,
                          // usernamestate
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
                          PopupMenuItem<String>(
                            value: 'block_user',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.block_outlined, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  isBlocked ? "Unblock User" : "Block User",
                                  style: TextStyle(color: Colors.black),
                                )
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
                            case 'block_user':
                              blockUser();
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

              // COMMENT
              Row(
                children: [
                  // Comment Button
                  CommentButton(
                    onTap: showComments,
                  ),

                  const SizedBox(width: 10),
                  // view count
                  Text("$commentNumber", style: TextStyle(color: Colors.grey)),

                  // like count
                  //Text(widget.comments.length.toString(),
                  //    style: TextStyle(color: Colors.grey)),

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

              if (postUsername == usernameState) DeleteButton(onTap: deletePost)
            ],
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 150),
            child: isCommentDialogOpen
                ? StreamBuilder<QuerySnapshot>(
                    key: ValueKey<bool>(
                        true), // Add a unique key for the first StreamBuilder
                    stream: FirebaseFirestore.instance
                        .collection("Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .orderBy("CommentTime", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Show loading circle if no data yet
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      }

                      // Conditional SizedBox to show only if there are comments
                      final hasComments = snapshot.data!.docs.isNotEmpty;

                      return Column(
                        children: [
                          if (hasComments)
                            SizedBox(height: 20)
                          else
                            SizedBox(height: 20),
                          if (mediaUrl != null) SizedBox(height: 5),

                          // Post comment
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              children: [
                                // Textfield
                                Expanded(
                                  child: MyTextField(
                                    controller: commentTextController,
                                    hintText: "Post a comment...",
                                    obscureText: false,
                                    maxLength: 0,
                                    isText: true,
                                  ),
                                ),

                                // Post button
                                IconButton(
                                  onPressed: postComment,
                                  icon: Icon(Icons.arrow_circle_up),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Rest of your code
                          ListView(
                            shrinkWrap: true, // For nested lists
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs.map((doc) {
                              // Get the comment
                              final commentData =
                                  doc.data() as Map<String, dynamic>;

                              // Return the comment
                              return Comment(
                                text: commentData["CommentText"],
                                user: commentData["CommentedBy"],
                                email: commentData["CommentedByEmail"],
                                usernameState: commentData["CommentedBy"],
                                time: formatDate(commentData["CommentTime"]),
                                postId: widget.postId,
                                commentId: doc.id,
                                isAdmin: isAdminState,
                              );
                            }).toList(),
                          )
                        ],
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    key: ValueKey<bool>(
                        false), // Add a unique key for the second StreamBuilder
                    stream: FirebaseFirestore.instance
                        .collection("Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .orderBy("Views", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Show loading circle if no data yet
                      if (!snapshot.hasData) {
                        return Center();
                      }

                      final comments = snapshot.data!.docs.map((doc) {
                        // Get the comment
                        final commentData = doc.data() as Map<String, dynamic>;

                        // Return the comment
                        return Comment(
                          text: commentData["CommentText"],
                          user: commentData["CommentedBy"],
                          email: commentData["CommentedByEmail"],
                          usernameState: commentData["CommentedBy"],
                          time: formatDate(commentData["CommentTime"]),
                          postId: widget.postId,
                          commentId: doc.id,
                          isAdmin: isAdminState,
                        );
                      }).toList();

                      return Column(
                        children: [
                          if (comments.isNotEmpty)
                            SizedBox(height: 20)
                          else
                            SizedBox(height: 5),
                          if (mediaUrl != null) SizedBox(height: 5),

                          // Display only the latest 3 comments
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                comments.length >= 3 ? 3 : comments.length,
                            itemBuilder: (context, index) {
                              return comments[index];
                            },
                          ),
                          if (widget.contextText != "" && comments.isEmpty)
                            SizedBox(height: 20),
                          if (widget.contextText != "")
                            CommunityContext(text: widget.contextText)
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
