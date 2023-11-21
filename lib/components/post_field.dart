// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MyPostField extends StatelessWidget {
  final TextEditingController controller;
  final Function()? imgFromGallery;
  final Function()? imgFromCamera;
  final String hintText;
  final bool obscureText;
  final bool showMediaPicker;

  const MyPostField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.imgFromGallery,
    required this.imgFromCamera,
    required this.showMediaPicker,
  });

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
              borderRadius: BorderRadius.circular(8.0),
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
        if (showMediaPicker == true)
          PopupMenuButton(
            icon: Icon(Icons.add_rounded, color: Colors.grey[500]),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'imgFromGallery',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: Colors.black,
                    ),
                    SizedBox(width: 7),
                    Text(
                      "Add Image",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'imgFromCamera',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.black,
                    ),
                    SizedBox(width: 7),
                    Text(
                      "Take Image",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
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
