import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComunityContext extends StatefulWidget {
  final String text;

  const ComunityContext({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  State<ComunityContext> createState() => _ComunityContextState();
}

class _ComunityContextState extends State<ComunityContext> {
  bool isLiked = false;
  bool isAdminState = false;
  String usernameState = "usernameState";
  String userEmail = "userEmail";
  String postUsername = "Test Username";
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(
          color: Colors.grey[600]!, // Replace with your desired border color
          width: 1.0, // Adjust the border width as needed
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Icon(Icons.search_rounded),
          const Text("Context you might want to know"),

          const SizedBox(height: 5),
          Divider(
            thickness: 0.5,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 5),

          Text(widget.text),

          // user, time
          Row(
            children: [
              Text(
                "admins",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
