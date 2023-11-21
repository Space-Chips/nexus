// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/chat_post.dart';
import 'package:nexus/components/text_box.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({
    super.key,
    required this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;
  late String address;
  late String website;
  late bool admin;
  late String updatedValue;

  // User
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool showPosts = true;
  bool isFollowing = false;
  bool isAdminState = false;
  late int followerCount;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUserData();
  }

  @override
  void dispose() {
    loadUserData();
    fetchUserData();
    super.dispose();
  }

  // Get the user data
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var isAdmin = userData['admin'];

      setState(() {
        isAdminState = isAdmin;
      });
    }
  }

  // Load user data
  Future<void> loadUserData() async {
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: widget.username);

    final snapshot = await docRef.get();

    if (snapshot.docs.isNotEmpty) {
      var userDocument = snapshot.docs[0];
      setState(() {
        isFollowing = userDocument['followers'].contains(currentUser.email);
        followerCount = userDocument['followers'].length;
      });
    } else {
      // Handle the case where no user is found.
    }
  }

  // show an account deletition dialog
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("DELETE YOUR ACCOUNT & DATA"),
        actions: [
          // "Yes" button
          TextButton(
            onPressed: () async {
              // Delete the user's data from Firestore
              final userDocs = await FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: currentUser.email)
                  .get();

              for (var doc in userDocs.docs) {
                await doc.reference.delete();
              }

              // Delete the user account from Firebase Auth
              await currentUser.delete();

              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text("Y E S"),
          ),

          // "Cancel" button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("C A N C E L"),
          )
        ],
      ),
    );
  }

  // Navigate to Home page
  void goToHomePage() {
    // Pop the menu drawer
    Navigator.pop(context);

    // Go to the profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  // Toggle following
  void toggleFollowing() async {
    // Access the document in Firebase using the document ID
    final userQuery = await FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: widget.username)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs[0];
      final userReference =
          FirebaseFirestore.instance.collection("users").doc(userDoc.id);

      final followersList = List<String>.from(userDoc['followers'] ?? []);

      if (!isFollowing) {
        followersList.add(currentUser.email!); // Use null-aware operator here
      } else {
        followersList
            .remove(currentUser.email!); // Use null-aware operator here
      }

      await userReference.update({
        'followers': followersList,
      });

      setState(() {
        isFollowing = !isFollowing;
        followerCount = followersList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: widget.username)
        .get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          56.0,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AppBar(
              title: GestureDetector(
                  onTap: () {
                    goToHomePage();
                  },
                  child: Text(widget.username)),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  goToHomePage();
                },
              ),
              elevation: 0.0,
              backgroundColor:
                  Theme.of(context).colorScheme.background.withOpacity(0.2),
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: docRef,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.size == 0) {
            return Center(child: Text('No matching user found.'));
          }

          var userDocument = snapshot.data!.docs[0];
          username = userDocument['username'];
          address = userDocument['address'];
          website = userDocument['website'];
          admin = userDocument['admin'];

          return CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.0),
                          color: Theme.of(context).colorScheme.primary),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                username[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  username,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (address != "")
                                  Icon(
                                    Icons.location_pin,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                                if (address != "")
                                  Text(
                                    userDocument['address'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                if (address != "") SizedBox(width: 20),
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                Text(
                                  "Joined ${formatDate(userDocument['joinDate'])}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                if (admin == true) SizedBox(width: 20),
                                if (admin == true)
                                  Icon(
                                    Icons.shield_outlined,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (website != "")
                                  Icon(
                                    Icons.link_outlined,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                                if (website != "") const SizedBox(width: 10),
                                if (website != "")
                                  Text(
                                    website,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                              ],
                            ),
                            if (website != "") const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userDocument['followers'].length.toString(),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  userDocument['followers'].length == 1
                                      ? 'follower'
                                      : 'followers',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    toggleFollowing();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      isFollowing ? Colors.white : Colors.blue,
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    isFollowing ? "Following" : "Follow",
                                    style: TextStyle(
                                      color: isFollowing
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (isAdminState == true && admin == false)
                                  const SizedBox(width: 10),
                                if (isAdminState == true && admin == false)
                                  IconButton(
                                    onPressed: showDeleteDialog,
                                    icon: Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MyTextBox(
                  text: userDocument['bio'],
                  sectionName: 'bio',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showPosts = true;
                          });
                        },
                        child: Text(
                          'Posts',
                          style: TextStyle(
                            color: showPosts
                                ? Theme.of(context).colorScheme.tertiary
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showPosts = false;
                          });
                        },
                        child: Text(
                          'Chats',
                          style: TextStyle(
                            color: !showPosts
                                ? Theme.of(context).colorScheme.tertiary
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              showPosts
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Posts")
                          .where('User', isEqualTo: widget.username)
                          .orderBy("TimeStamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child:
                                Center(child: Text('Error: ${snapshot.error}')),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(height: 50),
                                  Text('No posts found.'),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = snapshot.data!.docs[index];
                              return WallPost(
                                message: post['Message'],
                                user: post['User'],
                                userEmail: post['UserEmail'],
                                isAdminPost: post['isAdminPost'],
                                mediaDest: post['MediaDestination'],
                                contextText: post['Context'],
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                views: List<String>.from(post['Views'] ?? []),
                                time: formatDate(post['TimeStamp']),
                              );
                            },
                            childCount: snapshot.data!.docs.length,
                          ),
                        );
                      },
                    )
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Chat")
                          .where('User', isEqualTo: widget.username)
                          .orderBy("TimeStamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Text('Error: ${snapshot.error}'),
                                ],
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(height: 50),
                                  Text('No chats found.'),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = snapshot.data!.docs[index];
                              return ChatPosts(
                                message: post['Message'] ?? '',
                                user: post['User'] ?? '',
                                userEmail: post['UserEmail'] ?? '',
                                isAdminPost: post['isAdminPost'] ?? false,
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                time: formatDate(
                                    post['TimeStamp'] ?? DateTime.now()),
                              );
                            },
                            childCount: snapshot.data!.docs.length,
                          ),
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }
}
