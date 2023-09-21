// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nexus/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onSearchTap;
  final void Function()? onProfileTap;
  final void Function()? onLiveChatTap;
  final void Function()? onAdminChatTap;
  final void Function()? onSignOut;
  final void Function()? onThemeTap;
  final bool isAdmin;
  const MyDrawer({
    super.key,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onLiveChatTap,
    required this.onAdminChatTap,
    required this.onSignOut,
    required this.onThemeTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              // home list tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              // profile sarch list tile
              MyListTile(
                icon: Icons.search_outlined,
                text: 'S E A R C H',
                onTap: onSearchTap,
              ),

              // profile list tile
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),
              MyListTile(
                icon: Icons.bedtime,
                text: 'T H E M E',
                onTap: onThemeTap,
              ),
              MyListTile(
                icon: Icons.chat,
                text: 'L I V E  C H A T',
                onTap: onLiveChatTap,
              ),
              if (isAdmin == true)
                MyListTile(
                  icon: Icons.shield_rounded,
                  text: 'A D M I N  C H A T',
                  onTap: onAdminChatTap,
                ),
            ],
          ),

          // logout list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
