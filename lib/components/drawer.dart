import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onSearchTap;
  final void Function()? onProfileTap;
  final void Function()? onLiveChatTap;
  final void Function()? onAdminChatTap;
  final void Function()? onGroupChatTap;
  final void Function()? onSignOut;
  final void Function()? onThemeTap;

  final bool isAdmin;

  const MyDrawer({
    super.key,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onLiveChatTap,
    required this.onAdminChatTap,
    required this.onGroupChatTap,
    required this.onSignOut,
    required this.onThemeTap,
    required this.isAdmin,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  List<String> drawerItemOrder = [
    'HOME',
    'TEAMS',
    'SEARCH',
    'PROFILE',
    'THEME',
    'LIVE CHAT',
    'ADMIN CHAT',
  ];

  @override
  void initState() {
    super.initState();
    _loadDrawerItemOrder();
  }

  Future<void> _loadDrawerItemOrder() async {
    if (currentUser == null) {
      print("Skipping drawer item load because currentUser is null.");
      return;
    }

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userDocument = snapshot.docs[0];
        var firestoreOrder = userDocument['drawerItemOrder'];

        // Check if the Firestore order is a valid list
        if (firestoreOrder is List && firestoreOrder.isNotEmpty) {
          setState(() {
            drawerItemOrder = List<String>.from(firestoreOrder);
            print("Loaded drawer order from Firestore: $drawerItemOrder");
          });
        } else {
          print(
              "Firestore drawerItemOrder is empty or invalid, using default.");
          _saveDrawerItemOrder(); // Save default order if empty
        }
      } else {
        print("No document found for this user in Firestore.");
      }
    } catch (error) {
      print("Error loading drawer item order: $error");
    }
  }

  Future<void> _saveDrawerItemOrder() async {
    try {
      if (currentUser == null) {
        print("Can't save drawer item order because currentUser is null.");
        return;
      }

      var userCollection = FirebaseFirestore.instance.collection('users');
      var querySnapshot = await userCollection
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (querySnapshot.size > 0) {
        var userDocument = querySnapshot.docs[0];
        await userDocument.reference
            .update({'drawerItemOrder': drawerItemOrder});
        print("Drawer order saved to Firestore for ${currentUser.email}");
      }
    } catch (error) {
      print("Error saving drawer item order: $error");
    }
  }

  List<Widget> _buildDrawerItems() {
    Map<String, Widget> itemMap = {
      'HOME': MyListTile(
        key: ValueKey('HOME'),
        icon: Icons.home_rounded,
        text: 'H O M E',
        onTap: () => Navigator.pop(context),
      ),
      'SEARCH': MyListTile(
        key: ValueKey('SEARCH'),
        icon: Icons.search_outlined,
        text: 'S E A R C H',
        onTap: widget.onSearchTap,
      ),
      'PROFILE': MyListTile(
        key: ValueKey('PROFILE'),
        icon: Icons.person_rounded,
        text: 'P R O F I L E',
        onTap: widget.onProfileTap,
      ),
      'THEME': MyListTile(
        key: ValueKey('THEME'),
        icon: Icons.bedtime_rounded,
        text: 'T H E M E',
        onTap: widget.onThemeTap,
      ),
      'LIVE CHAT': MyListTile(
        key: ValueKey('LIVE CHAT'),
        icon: Icons.chat,
        text: 'L I V E  C H A T',
        onTap: widget.onLiveChatTap,
      ),
      if (widget.isAdmin)
        'ADMIN CHAT': MyListTile(
          key: ValueKey('ADMIN CHAT'),
          icon: Icons.shield_rounded,
          text: 'A D M I N  C H A T',
          onTap: widget.onAdminChatTap,
        ),
      'TEAMS': Padding(
        key: ValueKey('TEAMS'),
        padding: const EdgeInsets.only(left: 10.0),
        child: ExpansionTile(
          key: ValueKey('TEAMS_TILE'),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          leading: const Icon(
            Icons.group,
            color: Colors.white,
          ),
          title: const Text(
            'T E A M S',
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  'MY TEAMS',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: widget.onGroupChatTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  'EXPLORE TEAMS',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle tap
                },
              ),
            ),
          ],
        ),
      ),
    };

    return drawerItemOrder.map((itemKey) {
      if (itemMap.containsKey(itemKey)) {
        return itemMap[itemKey]!;
      } else {
        print("Invalid itemKey in drawer order: $itemKey");
        return Container();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Drawer(
          backgroundColor: Colors.grey[900]?.withOpacity(0.1),
          child: Column(
            children: [
              const DrawerHeader(
                child: Icon(Icons.person, color: Colors.white, size: 64),
              ),
              Expanded(
                child: ReorderableListView(
                  children: _buildDrawerItems(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final String item = drawerItemOrder.removeAt(oldIndex);
                      drawerItemOrder.insert(newIndex, item);
                      _saveDrawerItemOrder();
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MyListTile(
                  icon: Icons.logout_rounded,
                  text: 'L O G O U T',
                  onTap: widget.onSignOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const MyListTile({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        onTap: onTap,
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
