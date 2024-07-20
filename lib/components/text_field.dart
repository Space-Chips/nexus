// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isText;
  final int? maxLength;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isText,
    required this.obscureText,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return TextField(
      maxLength: maxLength != 0 ? maxLength : null,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
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
    );
  }
}
