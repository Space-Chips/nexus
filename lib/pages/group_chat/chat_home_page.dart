import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexus/components/chat_components/team_home_page_components/top_item_list.dart';
import 'package:nexus/helper/helper_methods.dart';
import 'package:nexus/pages/group_chat/chat_page.dart';
import 'package:nexus/services/user_profile.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ChatHomePage extends StatefulWidget {
  final String username;
  final String userId;
  const ChatHomePage({
    required this.username,
    required this.userId,
    super.key,
  });

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  bool isTeamsActive = false;
  final currentUser = FirebaseAuth.instance.currentUser;
  final textController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController teamLeagueController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  String selectedLeague = "FTC";

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

  void createTeam(String groupName, String teamLeage) async {
    String groupID =
        FirebaseFirestore.instance.collection("TeamDetial").doc().id;

    FirebaseFirestore.instance.collection("TeamDetail").doc(groupID).set(
      {
        'GroupName': groupName,
        'Admin': [currentUser?.email],
        'Members': [currentUser?.email],
        'GroupId': groupID,
        'TeamLeage': teamLeage,
        'LastMessage': "This group was  created by ${widget.username}",
        'LastMessageAuthor': widget.username,
        'LastMessageTimeStamp': Timestamp.now(),
        'CreatedOn': Timestamp.now(),
        'Description': "",
        'Likes': [currentUser?.email],
      },
    );
    FirebaseFirestore.instance
        .collection("TeamChat")
        .doc(groupID)
        .collection("Posts")
        .add(
      {
        'UserEmail': currentUser?.email,
        'UserId': currentUser?.getIdToken(),
        'Message': "This group was created by ${widget.username}",
        'isSystemPost': true,
        'TimeStamp': Timestamp.now(),
      },
    );

    Fluttertoast.showToast(
      msg: "${groupName.toLowerCase()} was created.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
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
                  // Group Name text field
                  TextField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.2),
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
                  ), // Group name text field
                  // Team League selector
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedLeague,
                    decoration: InputDecoration(
                      labelText: 'Team League',
                      labelStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.2),
                            width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.1),
                    ),
                    dropdownColor: Theme.of(context).colorScheme.secondary,
                    style: TextStyle(color: Colors.grey[300]),
                    items: <String>['FTC', 'FRC', 'FLL', 'Other']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedLeague = newValue; // Update selected value
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      createTeam(
                        groupNameController.text,
                        selectedLeague,
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

  void goToChatPage(
    String groupName,
    String lastMessage,
    String lastMessageAuthor,
    Timestamp lastMessageTimeStamp,
    String teamLeage,
    String groupId,
    String userId,
  ) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamChatPage(
          groupName: groupName,
          lastMessage: lastMessage,
          lastMessageAuthor: lastMessageAuthor,
          lastMessageTimeStamp: lastMessageTimeStamp,
          teamLeage: teamLeage,
          groupId: groupId,
          userId: userId,
        ),
      ),
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
                // ListView with StreamBuilder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('TeamDetail')
                      .where('Members', arrayContains: currentUser?.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final allPosts = snapshot.data!.docs;

                      // Check if there are any documents
                      if (allPosts.isNotEmpty) {
                        final firstGroup =
                            allPosts.first.data() as Map<String, dynamic>;

                        return ListView.separated(
                          padding: const EdgeInsets.only(
                              bottom: 154), // Padding for gradient height
                          itemCount: allPosts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 1),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Container(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 25,
                                ),
                                child: TeamHomeTopItem(
                                  title: firstGroup['GroupName']
                                      .toString()
                                      .toUpperCase(),
                                  lastPost: firstGroup['LastMessage'],
                                  lastPostAuthor:
                                      firstGroup['LastMessageAuthor'],
                                  lastPostTime:
                                      firstGroup['LastMessageTimeStamp'],
                                  onTap: () => goToChatPage(
                                    firstGroup['GroupName'],
                                    firstGroup['LastMessage'],
                                    firstGroup['LastMessageAuthor'],
                                    firstGroup['LastMessageTimeStamp'],
                                    firstGroup['TeamLeage'],
                                    firstGroup['GroupId'],
                                    widget.userId,
                                  ),
                                  league: firstGroup['TeamLeage'],
                                ),
                              );
                            }
                            return _buildSmallTeamCards(
                              title: firstGroup['GroupName']
                                  .toString()
                                  .toUpperCase(),
                              lastPost: firstGroup['LastMessage'],
                              lastPostAuthor: firstGroup['LastMessageAuthor'],
                              lastPostTime: firstGroup['LastMessageTimeStamp'],
                              onTap: () => goToChatPage(
                                firstGroup['GroupName'],
                                firstGroup['LastMessage'],
                                firstGroup['LastMessageAuthor'],
                                firstGroup['LastMessageTimeStamp'],
                                firstGroup['TeamLeage'],
                                firstGroup['GroupId'],
                                widget.userId,
                              ),
                              league: firstGroup['TeamLeage'],
                            );
                          },
                        );
                      } else {
                        // If no posts are available
                        return const Center(child: Text("No teams found."));
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  },
                ),
                // Gradient overlay at the bottom
                // Blurry gradient overlay at the bottom
                // Blurry gradient overlay at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRect(
                    // Add this to clip the blur effect
                    child: SizedBox(
                      height: 154,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context).colorScheme.surface,
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildJoinSection(),
          const SizedBox(height: 20),
          _buildCreateTeamButton(),
          const SizedBox(height: 20),
        ],
      )),
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

  Widget _buildSmallTeamCards({
    required String title,
    required String lastPost,
    required String lastPostAuthor,
    required Timestamp lastPostTime,
    required void Function() onTap,
    required String league,
  }) {
    return _buildSmallTeamCard(
      title,
      lastPost,
      lastPostAuthor,
      lastPostTime,
      onTap,
      league,
    );
  }

  Widget _buildSmallTeamCard(
    String title,
    String lastPost,
    String lastPostAuthor,
    Timestamp lastPostTime,
    void Function() onTap,
    String league,
  ) {
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
          Text(
            lastPost,
            style: const TextStyle(color: Color(0xFFCACACA), fontSize: 12),
          ),
          Text(
            "$lastPostAuthor\n${formatDate(lastPostTime)}",
            style: const TextStyle(color: Color(0xFF959595), fontSize: 10),
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
        shadowColor: const Color.fromARGB(0, 0, 0, 0),
        minimumSize: const Size(340, 58),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2)),
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
            shadowColor: const Color.fromARGB(0, 0, 0, 0),
            foregroundColor: Colors.green,
            backgroundColor: const Color.fromARGB(255, 110, 252, 114),
            //side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'J O I N',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
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
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.green,
          width: 1, // Border width (adjust as needed)
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 15,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
