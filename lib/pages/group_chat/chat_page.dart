// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/chat_components/team_home_page_components/team_chat_post.dart';
import 'package:nexus/components/chat_post.dart';
import 'package:nexus/components/post_field.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:redacted/redacted.dart';

class TeamChatPage extends StatefulWidget {
  final String groupName;
  final String lastMessage;
  final String lastMessageAuthor;
  final Timestamp lastMessageTimeStamp;
  final String teamLeage;
  final String groupId;
  final String userId;

  const TeamChatPage({
    required this.groupName,
    required this.lastMessage,
    required this.lastMessageAuthor,
    required this.lastMessageTimeStamp,
    required this.teamLeage,
    required this.groupId,
    required this.userId,
    super.key,
  });

  @override
  State<TeamChatPage> createState() => _HomePageState();
}

class _HomePageState extends State<TeamChatPage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  bool isAdminState = false;
  String usernameState = "Test";
  String emailState = "Test";

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    fetchUserData();
    _scrollController.dispose();

    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
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
        emailState = email;
      });
    } else {
      //print("User data not found");
    }
  }

  // post message
  void postMessage() {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance
          .collection("TeamChat")
          .doc(widget.groupId)
          .collection("Posts")
          .add({
        'UserEmail': currentUser.email,
        'UserId': widget.userId,
        'Message': textController.text,
        'isAdminPost': isAdminState,
        'TimeStamp': Timestamp.now(),
        'MediaDestination': '',
        'Context': "",
        'Likes': [],
        'Views': [],
      });
      textController.clear();
    }

    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          56.0,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                elevation: 2,
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.8),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.groupName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.teamLeage.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.lastMessageAuthor} · ${formatDate(widget.lastMessageTimeStamp)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      // Show team chat options menu
                    },
                  ),
                ],
                centerTitle: true,
                //backgroundColor:
                //   Theme.of(context).colorScheme.surface.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            // the wall
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("TeamChat")
                    .doc(widget.groupId)
                    .collection("Posts")
                    .orderBy('TimeStamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    final allPosts = snapshot.data!.docs;

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: allPosts.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        // Access each document individually
                        final post = allPosts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        // Check if 'isSystemPost' exists and assign it, or set it to false
                        final isSystemPost =
                            postData.containsKey('isSystemPost') ? true : false;

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: isSystemPost
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      //color: Theme.of(context)
                                      //    .colorScheme
                                      //    .secondary,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            post['Message'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "on ${formatDate(post['TimeStamp'])}",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary
                                                  .withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : TeamChatPost(
                                  key: ValueKey(post.id),
                                  message: post['Message'],
                                  userEmail: post['UserEmail'],
                                  isAdminPost: post['isAdminPost'],
                                  mediaDest: post['MediaDestination'],
                                  contextText: post['Context'],
                                  postId: post.id,
                                  likes: List<String>.from(post['Likes'] ?? []),
                                  views: List<String>.from(post['Views'] ?? []),
                                  time: post['TimeStamp'],
                                ).redacted(
                                  context: context,
                                  redact: true,
                                ),
                        );
                      },
                    );
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

            // post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // textfield
                  Expanded(
                    child: MyPostField(
                        controller: textController,
                        hintText: "Exprimez-vous ici...",
                        obscureText: false,
                        imgFromGallery: () {},
                        imgFromCamera: () {},
                        showMediaPicker: false),
                  ),

                  // post button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            // loged in as
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text("Logged in as : ${currentUser.email!}"),
            )
          ],
        ),
      ),
    );
  }
}
