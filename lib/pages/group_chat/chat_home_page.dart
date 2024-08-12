import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/chat_components/team_home_page_components/top_item_list.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  bool isTeamsActive = false;
  final textController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void createTeam(String groupName, String groupId, String teamLeage) async {
    if (textController.text.isNotEmpty && textController.text.length <= 200) {
      FirebaseFirestore.instance.collection("TeamDetail").add({
        'GroupName': groupName,
        'Admin': [],
        'Members': [],
        'GroupId': groupId,
        'TeamLeage': teamLeage,
        'LastMessage': "No messages found.",
        'LastMessageAuthor': "No messages found.",
        'LastMessageTimeStamp': "",
        'CreatedOn': Timestamp.now(),
        'Description': "",
        'Likes': [],
        'Views': [],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("N E X U S"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TeamHomeTopItem(
                          title: 'BAGUETTECHS',
                          lastPost: "Oui oui baguette",
                          lastPostAuthor: "Yursen le chef d'équipe",
                          lastPostTime: '10/20/2028  20:30',
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        _buildSmallTeamCards(),
                        const SizedBox(height: 20),
                        _buildSmallTeamCards(),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 150, // control the aera covered
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildJoinSection(),
            const SizedBox(height: 20),
            _buildCreateTeamButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 130,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildColumn('YOUR', 'TEAMS', isTeamsActive, () {
              if (!isTeamsActive) {
                setState(() {
                  isTeamsActive = true;
                  _controller.forward(from: 0);
                });
              }
            }),
            _buildColumn('PRIVATE', 'CHAT', !isTeamsActive, () {
              if (isTeamsActive) {
                setState(() {
                  isTeamsActive = false;
                  _controller.forward(from: 0);
                });
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(
      String topText, String bottomText, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double t = isActive ? _animation.value : 1 - _animation.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topText,
                style: TextStyle(
                  color: Color.lerp(const Color.fromARGB(150, 158, 158, 158),
                      const Color(0xFF9E9E9E), t),
                  fontSize: lerpDouble(28, 40, t),
                  height: 1.1, // Add this line
                ),
              ),
              Text(
                bottomText,
                style: TextStyle(
                  color: Color.lerp(const Color.fromARGB(150, 255, 255, 255),
                      Colors.white, t),
                  fontSize: lerpDouble(33.6, 48, t),
                  height: 1.1, // Add this line
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSmallTeamCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSmallTeamCard('FRENCH'),
        _buildSmallTeamCard('GEEKOS'),
      ],
    );
  }

  Widget _buildSmallTeamCard(String title) {
    return Container(
      width: 167,
      height: 175,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          const Spacer(),
          const Text(
            'Oui oui baguette',
            style: TextStyle(color: Color(0xFFCACACA), fontSize: 12),
          ),
          const Text(
            "Yursen le chef d'équipe\n01/07/2024 20:30",
            style: TextStyle(color: Color(0xFF959595), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildNumberBox(index + 1)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(340, 41),
            backgroundColor: const Color(0xFF3A3A3A),
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'J O I N',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberBox(int number) {
    return Container(
      width: 31,
      height: 41,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildCreateTeamButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(340, 58),
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'C R E A T E     T E A M',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
