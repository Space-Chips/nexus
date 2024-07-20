// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/components/my_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ignore: library_private_types_in_public_api
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late List<String> _drawerItemOrder;

  @override
  void initState() {
    super.initState();
    _loadDrawerItemOrder();
  }

  void _loadDrawerItemOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _drawerItemOrder = prefs.getStringList('drawerItemOrder') ??
          [
            'HOME',
            'SEARCH',
            'PROFILE',
            'THEME',
            'LIVE CHAT',
            'ADMIN CHAT',
            'TEAMS'
          ];
    });
  }

  void _saveDrawerItemOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('drawerItemOrder', _drawerItemOrder);
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
        key: UniqueKey(),
        icon: Icons.person_rounded,
        text: 'P R O F I L E',
        onTap: widget.onProfileTap,
      ),
      'THEME': MyListTile(
        key: UniqueKey(),
        icon: Icons.bedtime_rounded,
        text: 'T H E M E',
        onTap: widget.onThemeTap,
      ),
      'LIVE CHAT': MyListTile(
        key: UniqueKey(),
        icon: Icons.chat,
        text: 'L I V E  C H A T',
        onTap: widget.onLiveChatTap,
      ),
      if (widget.isAdmin)
        'ADMIN CHAT': MyListTile(
          key: UniqueKey(),
          icon: Icons.shield_rounded,
          text: 'A D M I N  C H A T',
          onTap: widget.onAdminChatTap,
        ),
      'TEAMS': Padding(
        key: UniqueKey(),
        padding: const EdgeInsets.only(left: 10.0),
        child: ExpansionTile(
          leading: Icon(
            Icons.group,
            color: Colors.white,
          ),
          title: Text(
            'T E A M S',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'MY TEAMS',
                  style: TextStyle(
                    // fontFamily: 'Times New Roman',
                    color: Colors.white,
                  ),
                ),
                onTap: widget.onGroupChatTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'EXPLORE TEAMS',
                  style: TextStyle(
                    //fontFamily: 'Times New Roman',
                    color: Colors.white,
                  ),
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

    return _drawerItemOrder.map((itemKey) => itemMap[itemKey]!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Drawer(
          backgroundColor: Colors.grey[900]?.withOpacity(0.1),
          child: Column(
            children: [
              DrawerHeader(
                child: Icon(Icons.person, color: Colors.white, size: 64),
              ),
              Expanded(
                child: ReorderableListView(
                  children: _buildDrawerItems(),
                  onReorder: (oldIndex, newIndex) {
                    HapticFeedback.selectionClick();

                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final String item = _drawerItemOrder.removeAt(oldIndex);
                      _drawerItemOrder.insert(newIndex, item);
                      _saveDrawerItemOrder();
                    });
                  },
                  proxyDecorator:
                      (Widget child, int index, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 0,
                          child: child,
                        );
                      },
                      child: child,
                    );
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
