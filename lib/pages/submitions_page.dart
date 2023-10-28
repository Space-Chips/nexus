// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, library_prefixes
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/challenge_components/submition_widget.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/home_page.dart';

class SubmitionsPage extends StatefulWidget {
  final String category;
  const SubmitionsPage({
    super.key,
    required this.category,
  });

  @override
  State<SubmitionsPage> createState() => _SubmitionsPageState();
}

class _SubmitionsPageState extends State<SubmitionsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  bool isAdminState = false;
  String usernameState =
      "Test Username (please contact me on play store in case you see this)";
  String emailState = "Test user Email";
  String userId = "Test user Id";
  String currentDocumentId = "";
  List<QueryDocumentSnapshot> allPosts = [];

  late String photoTitle = "Initialisation Error";
  late String photo = "Initialisation Error";
  late Timestamp photoTime = Timestamp.now();
  late String gamingTitle = "Initialisation Error";
  late String gaming = "Initialisation Error";
  late Timestamp gamingTime = Timestamp.now();
  late String cookingTitle = "Initialisation Error";
  late String cooking = "Initialisation Error";
  late Timestamp cookingTime = Timestamp.now();

  @override
  void initState() {
    super.initState();
    getId();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
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

  void getId() async {
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
              title: GestureDetector(
                onTap: () {
                  // Call your function here
                  goToHomePage();
                },
                child: Text(
                  "N E X U S",
                  selectionColor: Theme.of(context).colorScheme.primary,
                ),
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
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Challenge')
                    .doc(currentDocumentId)
                    .collection("Submitions")
                    .orderBy('TimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    allPosts = snapshot.data!.docs;
                    if (allPosts.isEmpty) {
                      return Center(
                        child: Text('There are no submissions thus far.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: allPosts.length,
                      itemBuilder: (context, index) {
                        final post = allPosts[index];
                        return SubmitionWidget(
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
                          category: widget.category,
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
              padding: const EdgeInsets.all(20.0),
              child: ChallengePicker(
                pickChallengeString: widget.category,
              ),
            ),

            /*Padding(
              padding: const EdgeInsets.all(25),
              child: Text("Logged in as: ${currentUser.email!}"),
            ),*/
          ],
        ),
      ),
    );
  }
}

class ChallengePicker extends StatefulWidget {
  String pickChallengeString;

  ChallengePicker({
    required this.pickChallengeString,
    Key? key,
  }) : super(key: key);

  @override
  _ChallengePickerState createState() => _ChallengePickerState();
}

class _ChallengePickerState extends State<ChallengePicker> {
  final postTextController = TextEditingController();

  int pickChallenge = 0;
  String timeLeft = "";
  bool showTextBar = false;

  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";
  String postUsername = "Test Username";
  String userId = "Test user Id";
  final commentTextController = TextEditingController();
  final reportTextController = TextEditingController();
  var commentTextcontrollerstring = "";
  // ignore: prefer_typing_uninitialized_variables
  var commentdata;
  late String mediaUrl = ""; // Initialize mediaUrl with an empty string
  bool isCommentDialogOpen = false;
  int submitionNumber = 0;
  List<QueryDocumentSnapshot> allPosts = [];

  @override
  void initState() {
    super.initState();
    setInitialCategory();
  }

  void setInitialCategory() {
    if (widget.pickChallengeString == "Gaming") {
      pickChallenge = 0;
    }
    if (widget.pickChallengeString == "Photo") {
      pickChallenge = 1;
    }
    if (widget.pickChallengeString == "Meme") {
      pickChallenge = 2;
    }
  }

  void goToSubmitionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubmitionsPage(category: widget.pickChallengeString),
      ),
    );
  }

  Future<void> getSubcollectionCount() async {
    QuerySnapshot collection = await FirebaseFirestore.instance
        .collection('Challenge')
        .where("name", isEqualTo: widget.pickChallengeString)
        .get();

    if (collection.docs.isNotEmpty) {
      DocumentReference documentRef = collection.docs.first.reference;

      QuerySnapshot subcollection =
          await documentRef.collection('Submitions').get();

      setState(() {
        submitionNumber = subcollection.docs.length;
      });
    }
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      QuerySnapshot collection = await FirebaseFirestore.instance
          .collection('Challenge')
          .where("name", isEqualTo: widget.pickChallengeString)
          .get();

      if (collection.docs.isNotEmpty) {
        DocumentReference documentRef = collection.docs.first.reference;

        QuerySnapshot subcollection =
            await documentRef.collection('Submitions').get();

        setState(() {
          submitionNumber = subcollection.docs.length;
        });
      }
    });
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
        userEmail = email;
      });
    }
  }

  /*
  void _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        _selectedImageWidget = Image.file(_photo!);
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                _buildTitle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChallengeTitle(0, 'Games', "Gaming"),
        const SizedBox(width: 40),
        _buildChallengeTitle(1, 'Photo', "Photo"),
        const SizedBox(width: 40),
        _buildChallengeTitle(2, 'Meme', "Meme"),
      ],
    );
  }

  Widget _buildChallengeTitle(int index, String title, String name) {
    return GestureDetector(
      onTap: () {
        goToSubmitionPage();

        setState(() {
          pickChallenge = index;
          widget.pickChallengeString = name;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: pickChallenge == index
              ? Theme.of(context).colorScheme.tertiary
              : Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
