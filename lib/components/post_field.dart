// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MyPostField extends StatelessWidget {
  final TextEditingController controller;
  final Function()? imgFromGallery;
  final Function()? imgFromCamera;
  final String hintText;
  final bool obscureText;

  const MyPostField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.imgFromGallery,
    required this.imgFromCamera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Stack(
      alignment: Alignment.centerRight, // Align the button to the right
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Theme.of(context).colorScheme.primary,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
        // Display the menue
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[500]), // add this line
          itemBuilder: (_) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'imgFromGallery',
              child: SizedBox(
                width: 100,
                // height: 30,

                child: Text(
                  "add image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'imgFromCamera',
              child: SizedBox(
                width: 100,
                // height: 30,
                child: Text(
                  "take image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
          onSelected: (index) async {
            switch (index) {
              case 'imgFromGallery':
                imgFromGallery!();
                break;
              case 'imgFromCamera':
                imgFromCamera!();
                break;
            }
          },
        ),
      ],
    );
  }
}
