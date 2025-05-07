import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onUserTap;

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
        children: <Widget>[
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
            title: Text('Home'),
            onTap: onHomeTap,
          ),
          ListTile(
            title: Text('Settings'),
            onTap: onSettingsTap,
          ),
          ListTile(
            title: Text('User'),
            onTap: onUserTap,
          ),
        ],
      ),
    );
  }
}
