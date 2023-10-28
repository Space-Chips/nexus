// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CommunityContext extends StatefulWidget {
  final String text;

  const CommunityContext({super.key, required this.text});

  @override
  _CommunityContextState createState() => _CommunityContextState();
}

class _CommunityContextState extends State<CommunityContext> {
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
        children: <Widget>[
          _buildTitle(),
          const SizedBox(height: 5),
          Divider(
            thickness: 0.5,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 5),
          Text(widget.text),
          _buildAdditionalInfo(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          Icons.group,
          size: 22,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 7),
        const Text(
          "Context you might want to know",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Send on Earth",
              style: TextStyle(color: Colors.grey[400]),
            ),
            // Add more widgets to display other information if needed.
          ],
        ),
      ],
    );
  }
}
