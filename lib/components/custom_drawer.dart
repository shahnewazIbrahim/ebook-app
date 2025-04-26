import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String title;
  final Function onHomeTap;
  final Function onSettingsTap;
  final Function onUserTap;

  const CustomDrawer({
    Key? key,
    required this.title,
    required this.onHomeTap,
    required this.onSettingsTap,
    required this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              onHomeTap();
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              onSettingsTap();
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: const Text('User'),
            onTap: () {
              onUserTap();
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
