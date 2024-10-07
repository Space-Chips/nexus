import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/chat_components/team_home_page_components/top_item_list.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  bool isTeamsActive = false;
  final textController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController teamLeagueController = TextEditingController();
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
      String groupID =
          FirebaseFirestore.instance.collection("TeamDetial").doc().id;

      FirebaseFirestore.instance.collection("TeamDetail").doc(groupID).set(
        {
          'GroupName': groupName,
          'Admin': [],
          'Members': [],
          'GroupId': groupID,
          'TeamLeage': teamLeage,
          'LastMessage': "",
          'LastMessageAuthor': "",
          'LastMessageTimeStamp': "",
          'CreatedOn': Timestamp.now(),
          'Description': "",
          'Likes': [],
          'Views': [],
        },
      );
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

  void _showCreateTeamModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (BuildContext _) {
        return [
          WoltModalSheetPage(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create New Team',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: TextStyle(color: Colors.grey[300]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.1),
                    ),
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: teamLeagueController,
                    decoration: InputDecoration(
                      labelText: 'Team League',
                      labelStyle: TextStyle(color: Colors.grey[300]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.1),
                    ),
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      createTeam(
                        groupNameController.text,
                        '', // GroupId will be generated in the function
                        teamLeagueController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Create Team',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ],
              ),
            ),
          )
        ];
      },
    );
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
            const SizedBox(height: 30),
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
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
                        height: 50, // control the aera covered
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.9),
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.0)
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
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: lerpDouble(28, 40, t),
                  height: 1.1, // Add this line
                ),
              ),
              Text(
                bottomText,
                style: TextStyle(
                  color: Colors.grey,
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
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 25),
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

  Widget _buildCreateTeamButton() {
    return ElevatedButton(
      onPressed: () {
        _showCreateTeamModal(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(340, 58),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'C R E A T E     T E A M',
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
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
          backgroundColor: Colors.grey,
          //side: const BorderSide(color: Colors.white),
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
      color: Colors.grey[700],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        '$number',
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
  );
}
