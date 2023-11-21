// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/editable_text_box.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/home_page.dart';

class ProfilePageSettings extends StatefulWidget {
  const ProfilePageSettings({super.key});

  @override
  State<ProfilePageSettings> createState() => _ProfilePageSettingsState();
}

class _ProfilePageSettingsState extends State<ProfilePageSettings> {
  late String updatedValue; // Declare updatedValue as a class-level variable
  late String username;
  late String address;
  late String website;
  late String email;

  late bool admin;

  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool showPosts = true;
  bool isFollowing = false;
  bool isBlocked = false;

  var blockedUsersEmails = [];

  @override
  void initState() {
    super.initState();
  }

/*
  @override
  void dispose() {
    super.dispose();
    fetchUserData();
    fetchPostData();
  }*/

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
              // show an account deletition dialog
              try {
                // Delete the user's data from Firestore
                final userDocs = await FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: currentUser.email)
                    .get();

                final postDocs = await FirebaseFirestore.instance
                    .collection("Posts")
                    .where("UserEmail", isEqualTo: currentUser.email)
                    .get();

                final chatDocs = await FirebaseFirestore.instance
                    .collection("Chat")
                    .where("UserEmail", isEqualTo: currentUser.email)
                    .get();

                for (var doc in userDocs.docs) {
                  await doc.reference.delete();
                }
                for (var doc in postDocs.docs) {
                  await doc.reference.delete();
                }
                for (var doc in chatDocs.docs) {
                  await doc.reference.delete();
                }

                // Delete the user account from Firebase Auth
                await currentUser.delete();

                // Dismiss the dialog
                Navigator.pop(context);
              } on FirebaseAuthException catch (e) {
                Fluttertoast.showToast(
                  msg: e.code,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
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

  Future<void> editField(String field) async {
    var userCollection = FirebaseFirestore.instance.collection('users');
    var userQuery = userCollection.where('email', isEqualTo: currentUser.email);

    var querySnapshot = await userQuery.get();

    if (querySnapshot.size > 0) {
      var userDocument = querySnapshot.docs[0];

      updatedValue =
          userDocument[field]; // Initialize updatedValue with the current value

      String? newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.length > 2) {
                      updatedValue = value; // Update the updatedValue variable
                    } else {
                      // pop box
                    }
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                if (updatedValue.length > 2) {
                  // add coment
                  Navigator.of(context).pop(updatedValue);
                  // pop box
                } else {
                  // pop box
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (newValue != null && newValue.trim().isNotEmpty) {
        await userDocument.reference.update({field: newValue});
        setState(() {
          username = newValue;
        });
      }
    }
  }

  // navigate to home page
  void goToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: currentUser.email)
        .get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          56.0,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: AppBar(
              title: GestureDetector(
                onTap: () {
                  // Call your function here
                  goToHomePage();
                },
                child: Text(
                  "P R O F I L E  P A G E",
                  selectionColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              centerTitle: true,

              elevation: 0.0,
              // backgroundColor: Colors.black.withOpacity(0.2),
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
            var email = userDocument['email'];
            username = userDocument['username'];
            address = userDocument['address'];
            website = userDocument['website'];
            admin = userDocument['admin'];

            return ListView(
              children: [
                // const SizedBox(height: 25),
                /*Icon(
                  Icons.person,
                  size: 72,
                ),*/

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 100.0,
                    height: 180.0,
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
                                    color: Colors.grey[100],
                                  ),
                                ),
                              ),
                              Text(
                                username,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13),
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
                                  if (website != "")
                                    Text(
                                      website,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  Text(
                                    userDocument['followers'].length.toString(),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isBlocked
                                        ? userDocument['followers'].length == 1
                                            ? 'follower'
                                            : 'followers'
                                        : 'unblock',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[700]),
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
                // const SizedBox(height: 10),

                MyEditableTextBox(
                  text: username, // Now you can use the username variable here
                  sectionName: 'username',
                  onPressed: () => editField("username"),
                ),
                MyEditableTextBox(
                  text: userDocument['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField("bio"),
                ),
                SizedBox(
                  width: double
                      .infinity, // Make sure the container is as wide as its parent
                  child: GestureDetector(
                    onTap: showDeleteDialog,
                    child: SizedBox(
                      width: 60, // Adjust the width as needed
                      height: 50,
                      child: Container(
                        padding: EdgeInsets.all(
                            10), // Reduce padding to fit the text

                        child: Center(
                          child: Text(
                            "Delete your account data",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My posts',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Posts")
                      .where('UserEmail', isEqualTo: currentUser.email)
                      .orderBy("TimeStamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Align(
                        alignment: Alignment.center,
                        child: Center(
                          child: Text('No posts found.'),
                        ),
                      );
                    }

                    // Display the posts in a ListView
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
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
                          /*comments:
                              List<String>.from(post['CommentCount'] ?? []),*/
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  },
                )
              ],
            );
          }),
    );
  }
}
