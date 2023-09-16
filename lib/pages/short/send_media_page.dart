// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/components/text_field.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nexus/pages/home_page.dart';
import 'package:path/path.dart' as Path;

class SendMediaPage extends StatefulWidget {
  final String emailState;
  final String usernameState;
  final bool isAdminState;
  final File? photo;
  const SendMediaPage({
    super.key,
    required this.emailState,
    required this.usernameState,
    required this.isAdminState,
    required this.photo,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SendMediaPageState createState() => _SendMediaPageState();
}

class _SendMediaPageState extends State<SendMediaPage> {
  String userEmailFilter = ''; // Initialize filter string
  File? _photo;
  Widget _selectedImageWidget = Container();

  // text controller
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _photo = widget.photo;
    if (widget.photo != null) {
      _selectedImageWidget = Image.file(widget.photo!);
    }
  }

  // post message
  void postMessage() async {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      String? fileName;

      if (_photo != null) {
        fileName = Path.basename(_photo!.path);
      }

      // store in firebase
      FirebaseFirestore.instance.collection("Posts").add({
        'UserEmail': widget.emailState,
        'User': widget.usernameState,
        'Message': textController.text,
        'isAdminPost': widget.isAdminState,
        'TimeStamp': Timestamp.now(),
        'MediaDestination': fileName != null ? 'media/$fileName' : '',
        'Likes': [],
      });
      textController.clear();

      // Display the selected image in the media page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

      // Clear the selected image
      setState(() {
        _selectedImageWidget = Container();
        _photo = null; // Clear the selected photo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                reverse:
                    true, // Set this to true to display items in reverse order

                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent, // Transparent at the top
                            Colors.black.withOpacity(
                                0.7), // Opacity and color of the gradient
                          ],
                        ),
                      ),
                      child: _selectedImageWidget,
                    ),
                  ),
                  if (_photo != null)
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(8.0),
                                topRight: Radius.circular(25.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(8.0),
                                topRight: Radius.circular(25.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              child: _selectedImageWidget,
                            ),
                          ),
                        ),
                        /*Positioned(
                          top: 10.0,
                          left: 10.0,
                          child: IconButton(
                            onPressed: () {
                              // Handle clearing the selected image here
                              setState(() {
                                _selectedImageWidget = Container();
                                _photo = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),*/
                      ],
                    ),
                ],
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
                      hintText: "Post a message...",
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
          ],
        ),
      ),
    );
  }
}
