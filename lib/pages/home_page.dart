// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, library_prefixes
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/components/challenge_components/challenge_widget.dart';
import 'package:nexus/pages/settings/your-account/your_account.dart';
import 'package:path/path.dart' as Path;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:nexus/components/drawer.dart';
import 'package:nexus/components/post_field.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/admin_chat.dart';
import 'package:nexus/pages/livechat_page.dart';
import 'package:nexus/pages/user_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _photo;
  Widget _selectedImageWidget = Container();
  bool isAdminState = false;
  String usernameState =
      "Test Username (please contact me on play store in case you see this)";
  String emailState = "Test user Email";
  String userId = "Test user Id";
  int subcollectionCount = 0;
  List<QueryDocumentSnapshot> allPosts = [];

  late String photoTitle = "Initialisation Error";
  late String photo = "Initialisation Error";
  late Timestamp photoTime = Timestamp.now();
  late String gamingTitle = "Initialisation Error";
  late String gaming = "Initialisation Error";
  late Timestamp gamingTime = Timestamp.now();
  late String memeTitle = "Initialisation Error";
  late String meme = "Initialisation Error";
  late Timestamp memeTime = Timestamp.now();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchChallengeData();
    checkAccountAndSignOut();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> checkAccountAndSignOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not signed in, nothing to check or sign out.
      return;
    }

    try {
      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (freshUser == null) {
        // The user's account no longer exists, sign them out.
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      // An error occurred while refreshing the user's profile.
    }
  }

  // Get the user data
  void fetchChallengeData() async {
    // Get photo challenge detail
    QuerySnapshot photoSnapshot = await FirebaseFirestore.instance
        .collection("Challenge")
        .where("name", isEqualTo: "Photo")
        .get();

    if (photoSnapshot.docs.isNotEmpty) {
      var challengeData =
          photoSnapshot.docs.first.data() as Map<String, dynamic>;
      var title = challengeData['Title'];
      var description = challengeData['Description'];
      var timeStamp = challengeData['TimeStamp'];

      setState(() {
        photoTitle = title;
        photo = description;
        photoTime = timeStamp;
      });
    }

    // Get gaming challenge detail
    QuerySnapshot gamingSnapshot = await FirebaseFirestore.instance
        .collection("Challenge")
        .where("name", isEqualTo: "Gaming")
        .get();

    if (gamingSnapshot.docs.isNotEmpty) {
      var challengeData =
          gamingSnapshot.docs.first.data() as Map<String, dynamic>;
      var gametitle = challengeData['Title'];
      var description = challengeData['Description'];
      var timeStamp = challengeData['TimeStamp'];

      setState(() {
        gamingTitle = gametitle;
        gaming = description;
        gamingTime = timeStamp;
      });
    }

    // Get meme challenge detail
    QuerySnapshot memeSnapshot = await FirebaseFirestore.instance
        .collection("Challenge")
        .where("name", isEqualTo: "Meme")
        .get();

    if (memeSnapshot.docs.isNotEmpty) {
      var challengeData =
          memeSnapshot.docs.first.data() as Map<String, dynamic>;
      var title = challengeData['Title'];
      var description = challengeData['Description'];
      var timeStamp = challengeData['TimeStamp'];

      setState(() {
        memeTitle = title;
        meme = description;
        memeTime = timeStamp;
      });
    }
  }

  // Get the user data
  void fetchUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: currentUser.email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var username = userData['username'];
      var isAdmin = userData['admin'];
      var email = userData['email'];

      setState(() {
        usernameState = username;
        isAdminState = isAdmin;
        emailState = email;
      });
    }
  }

  // Pick the image from gallery
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
        _selectedImageWidget = Image.file(_photo!);
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = Path.basename(_photo!.path);
    const destination = 'files/';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('media/$fileName');
      await ref.putFile(_photo!);
    } catch (e) {
      // Handle the error
    }
  }

  void postMessage() async {
    if (textController.text.isNotEmpty) {
      String? fileName;

      if (_photo != null) {
        fileName = Path.basename(_photo!.path);
      }

      FirebaseFirestore.instance.collection("Posts").add({
        'UserEmail': emailState,
        'User': usernameState,
        'UserId': userId,
        'Message': textController.text,
        'isAdminPost': isAdminState,
        'TimeStamp': Timestamp.now(),
        'MediaDestination': fileName != null ? 'media/$fileName' : '',
        'Context': "",
        'Likes': [],
        'Views': [],
      });
      textController.clear();

      setState(() {
        _selectedImageWidget = Container();
        _photo = null;
      });
    }
  }

  void goToSearchPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSearch(),
      ),
    );
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YourAccountPage(),
      ),
    );
  }

  void goToLiveChatPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveChatPage(),
      ),
    );
  }

  void goToAdminChatPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text(
                "N E X U S",
                selectionColor: Theme.of(context).colorScheme.primary,
              ),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor:
                  Theme.of(context).colorScheme.background.withOpacity(0.2),
              actions: [
                IconButton(
                  onPressed: signOut,
                  icon: Icon(Icons.logout),
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ],
            ),
          ),
        ),
      ),
      drawer: MyDrawer(
        onSearchTap: goToSearchPage,
        onSignOut: signOut,
        onProfileTap: goToProfilePage,
        onLiveChatTap: goToLiveChatPage,
        onAdminChatTap: goToAdminChatPage,
        isAdmin: isAdminState,
        onThemeTap: () {
          Future.delayed(Duration(milliseconds: 5), () {
            setState(() {
              AdaptiveTheme.of(context).toggleThemeMode();
            });
          });
        },
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
                    .orderBy('TimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    allPosts = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount:
                          allPosts.length + 1, // Add 1 for the extra item
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Return your widget for the first item
                          return Container(
                            margin:
                                EdgeInsets.only(top: 25, left: 25, right: 25),
                            child: ChallengeWidget(
                              gamingTitle: gamingTitle,
                              gaming: gaming,
                              memeTitle: memeTitle,
                              meme: meme,
                              photoTitle: photoTitle,
                              photo: photo,
                              photoTime: photoTime,
                            ),
                          );
                        }

                        final post = allPosts[index - 1];
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
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyPostField(
                      controller: textController,
                      hintText: "Post a message...",
                      obscureText: false,
                      imgFromGallery: imgFromGallery,
                      imgFromCamera: imgFromCamera,
                    ),
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_up),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text("Logged in as: ${currentUser.email!}"),
            ),
            if (_photo != null)
              _selectedImageWidget = Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: _selectedImageWidget,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedImageWidget = Container();
                          _photo = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            if (_photo != null) SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
