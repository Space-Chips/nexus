// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/admin_chat_post.dart';
import 'package:nexus/components/post_field.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/tools/post_report_page.dart';
import 'package:nexus/pages/tools/user_chat_search_page.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _HomePageState();
}

class _HomePageState extends State<AdminChatPage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  bool isAdminState = false;
  String usernameState = "Test";
  String emailState = "Test";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    fetchUserData();
    super.dispose();
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
      FirebaseFirestore.instance.collection("Admin_Chat").add(
        {
          'User': usernameState,
          'UserEmail': currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'isAdminPost': isAdminState,
          'Likes': [],
        },
      );
    }

    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "A D M I N  C H A T",
          selectionColor: Theme.of(context).colorScheme.primary,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // Display the menue
          PopupMenuButton(
            color: Colors.white,
            icon: Icon(Icons.more_vert, color: Colors.grey[500]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                value: 'search_messages',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      "Search message by email",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'reports',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.report, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      "Reports",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
            ],
            onSelected: (index) async {
              switch (index) {
                case 'search_messages':
                  // go to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPostsPage(),
                    ),
                  );
                  break;
                case 'reports':
                  // go to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPage(),
                    ),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Admin_Chat')
                    .orderBy(
                      "TimeStamp",
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get messages
                        final post = snapshot.data!.docs[index];
                        return AdminChatPosts(
                          message: post['Message'],
                          user: post['User'],
                          userEmail: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
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
                      hintText: 'Postez votre rumeur...',
                      obscureText: false,
                      imgFromGallery: () {},
                      imgFromCamera: () {},
                      showMediaPicker: false,
                    ),
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
