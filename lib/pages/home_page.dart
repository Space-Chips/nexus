// ignore_for_file: prefer_const_constructors

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/drawer.dart';
import 'package:nexus/components/text_field.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/admin_chat.dart';
import 'package:nexus/pages/livechat_page.dart';
import 'package:nexus/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      FirebaseFirestore.instance.collection("Posts").add({
        'UserEmail': emailState,
        'User': usernameState,
        'Message': textController.text,
        'isAdminPost': isAdminState,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    textController.clear();
  }

  // navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void goToLiveChatPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveChatPage(),
      ),
    );
  }

  void goToAdminChatPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "N E X U S",
          selectionColor: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
            color: Theme.of(context).colorScheme.tertiary,
          )
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onLiveChatTap: goToLiveChatPage,
        onAdminChatTap: goToAdminChatPage,
        isAdmin: isAdminState,
        onThemeTap: () {
          AdaptiveTheme.of(context).toggleThemeMode();
          // Wrap in a function
        },
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
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
                        return WallPost(
                          message: post['Message'],
                          user: post['User'],
                          userEmail: post['UserEmail'],
                          isAdminPost: post['isAdminPost'],
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
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
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
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Postez votre rumeur...',
                      obscureText: false,
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
            ),
          ],
        ),
      ),
    );
  }
}
