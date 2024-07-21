import 'package:flutter/material.dart';

class TeamHomeTopItem extends StatefulWidget {
  final String title;
  final String lastPost;
  final String lastPostAuthor;
  final String lastPostTime;
  const TeamHomeTopItem({
    super.key,
    required this.title,
    required this.lastPost,
    required this.lastPostAuthor,
    required this.lastPostTime,
  });

  @override
  State<TeamHomeTopItem> createState() => _TeamHomeTopItemState();
}

class _TeamHomeTopItemState extends State<TeamHomeTopItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 354,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          SizedBox(height: 20),
          Text(
            widget.lastPost,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            widget.lastPostAuthor,
            style: TextStyle(color: Color(0xFF959595), fontSize: 10),
          ),
          const SizedBox(height: 5),
          Text(
            widget.lastPostTime,
            style: TextStyle(color: Color(0xFF959595), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
