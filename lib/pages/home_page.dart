// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, library_prefixes
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/components/challenge_components/challenge_widget.dart';
import 'package:nexus/pages/settings/your-account/your_account.dart';
import 'package:path/path.dart' as Path;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:nexus/components/drawer.dart';
import 'package:nexus/components/post_field.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/tools/admin_chat.dart';
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

  late String photoTitle = "Loading...";
  late String photo = "Loading...";
  late Timestamp photoTime = Timestamp.now();
  late String gamingTitle = "Loading...";
  late String gaming = "Loading...";
  late Timestamp gamingTime = Timestamp.now();
  late String memeTitle = "Loading...";
  late String meme = "Loading...";
  late Timestamp memeTime = Timestamp.now();

  var blockedUsersEmails = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchChallengeData();
    checkAccountAndSignOut();
  }

  @override
  void dispose() {
    fetchUserData();
    fetchChallengeData();
    checkAccountAndSignOut();
    super.dispose();
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
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: currentUser.email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        var blockedUsers = userData['blockedUsersEmails'] ??
            <String>[]; // Initialize with an empty list if null
        var username = userData['username'];
        var isAdmin = userData['admin'];
        var email = userData['email'];

        setState(() {
          blockedUsersEmails = blockedUsers;
          usernameState = username;
          isAdminState = isAdmin;
          emailState = email;
        });
      }
    } catch (e) {
      //
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

  Future<void> uploadFile() async {
    if (_photo == null) return;
    final fileName = Path.basename(_photo!.path);
    const destination = 'files/';

    try {
      // Read the image file
      final imageBytes = await _photo!.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      // Check if the image is null
      if (image == null) {
        // Handle the error
        return;
      }

      // Optionally, you can resize the image to reduce its dimensions
      // image = img.copyResize(image, width: 800, height: 600);

      // Convert the image to JPEG with a specified quality (adjust quality as needed)
      final compressedBytes = img.encodeJpg(image, quality: 80);

      // Create a reference to the Firebase Storage location
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('media/$fileName');

      // Upload the compressed image
      await ref.putData(compressedBytes);
    } catch (e) {
      // Handle the error
    }
  }

  void postMessage() async {
    if (textController.text.isNotEmpty && textController.text.length <= 200) {
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
    } else {
      if (textController.text.isEmpty) {
        Fluttertoast.showToast(
          msg: "Post can't be blank.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
        return;
      }
      if (textController.text.length >= 200) {
        Fluttertoast.showToast(
          msg: "Post limited to 200 characters.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
        return;
      }
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

  void goToGroupChatPage() {
    Navigator.pop(context);
    //Navigator.push(context
    // MaterialPageRoute(
    //builder: (context) => const GetStarted(),
    // ),
    //   );
  }

  @override
  Widget build(BuildContext context) {
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
            child: AppBar(
              title: Text(
                "N E X U S",
                selectionColor: Theme.of(context).colorScheme.primary,
              ),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.2),
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
        onGroupChatTap: goToGroupChatPage,
        isAdmin: isAdminState,
        onThemeTap: () {
          Future.delayed(Duration(milliseconds: 5), () {
            setState(() {
              HapticFeedback.heavyImpact();
              AdaptiveTheme.of(context).toggleThemeMode();
            });
          });
        },
      ),
      body: Center(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta! < -20) {
              Scaffold.of(context).openDrawer();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Posts')
                      .orderBy('TimeStamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final allPosts = snapshot.data!.docs;

                      // Continue with your logic to filter posts based on blocked users (blockedUsersEmails)
                      final filteredPosts = allPosts
                          .where((post) =>
                              !blockedUsersEmails.contains(post['UserEmail']))
                          .toList();

                      return ListView.separated(
                        itemCount: filteredPosts.length + 1,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 1),
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

                          final post = filteredPosts[index - 1];
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
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
                        showMediaPicker: true,
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
      ),
    );
  }
}
