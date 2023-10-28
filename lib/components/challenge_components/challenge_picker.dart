// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, library_prefixes

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/components/post_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/pages/submitions_page.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChallengePicker extends StatefulWidget {
  //final List<String> comments;

  const ChallengePicker({
    Key? key,
  }) : super(key: key);

  @override
  _ChallengePickerState createState() => _ChallengePickerState();
}

class _ChallengePickerState extends State<ChallengePicker> {
  final postTextController = TextEditingController();

  int pickChallenge = 0;
  String pickChallengeString = "Gaming";
  String timeLeft = "";
  bool showTextBar = false;

  final currentUser = FirebaseAuth.instance.currentUser!;
  final ImagePicker _picker = ImagePicker();
  File? _photo;
  Widget _selectedImageWidget = Container();
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";
  String postUsername = "Test Username";
  String userId = "Test user Id";
  final commentTextController = TextEditingController();
  final reportTextController = TextEditingController();
  var commentTextcontrollerstring = "";
  var commentdata;
  late String mediaUrl = ""; // Initialize mediaUrl with an empty string
  final storage = FirebaseStorage.instance;
  bool isCommentDialogOpen = false;
  int submitionNumber = 0;
  List<QueryDocumentSnapshot> allPosts = [];

  @override
  void initState() {
    super.initState();
  }

  void goToSubmitionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitionsPage(category: pickChallengeString),
      ),
    );
  }

  Future<void> getSubcollectionCount() async {
    QuerySnapshot collection = await FirebaseFirestore.instance
        .collection('Challenge')
        .where("name", isEqualTo: pickChallengeString)
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
          .where("name", isEqualTo: pickChallengeString)
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

  void postSubmition() async {
    if (postTextController.text.isNotEmpty) {
      String? fileName;

      if (_photo != null) {
        fileName = Path.basename(_photo!.path);
      }

      /*if (_photo != null) {
      fileName = Path.basename(_photo!.path);
    }*/

      Fluttertoast.showToast(
        msg: "Submission sent successfully",
        toastLength: Toast.LENGTH_SHORT, // Duration for the notification
        gravity:
            ToastGravity.BOTTOM, // Location of the notification on the screen
        backgroundColor: Colors.green, // Background color of the notification
        textColor: Colors.white, // Text color of the notification
      );

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Challenge")
          .where("name", isEqualTo: pickChallengeString)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to add to the first matching document (you can loop through querySnapshot if needed)
        DocumentReference documentReference = querySnapshot.docs[0].reference;

        documentReference.collection("Submitions").add({
          'UserEmail': userEmail,
          'User': usernameState,
          'UserId': userId,
          'Message': postTextController.text,
          'isAdminPost': isAdminState,
          'TimeStamp': Timestamp.now(),
          'MediaDestination': fileName != null ? 'media/$fileName' : '',
          'Context': "",
          'Likes': [],
          'Views': [],
        });

        postTextController.clear();

        setState(() {
          _selectedImageWidget = Container();
          _photo = null;
        });
      }
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
          pickChallengeString = name;
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

  Widget _secondaryInfos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //Icon(Icons.access_time, color: Colors.grey[600]),
        Text(timeLeft, style: TextStyle(color: Colors.grey[600])),
        //Icon(Icons.star, color: Colors.grey[600]),
        Text("   ", style: TextStyle(color: Colors.grey[600])),
        Text(submitionNumber.toString(),
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton("SUBMIT", () {
          setState(() {});
          showTextBar = !showTextBar;

          // _showAddPostDialog();
        }),
        const SizedBox(width: 20),
        _buildActionButton("VIEW", () {
          goToSubmitionPage();
        }),
      ],
    );
  }

  Widget _postWidget() {
    return Column(
      children: [
        const SizedBox(height: 15),

        // Post comment
        Row(
          children: [
            // Textfield
            Expanded(
              child: MyPostField(
                controller: postTextController,
                hintText: "Post your submission...",
                obscureText: false,
                imgFromGallery: imgFromGallery,
                imgFromCamera: imgFromCamera,
              ),
            ),

            // Post button
            IconButton(
              onPressed: postSubmition,
              icon: const Icon(Icons.arrow_circle_up),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
