import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;
  final VoidCallback onLoginTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onUserTap;

  const CustomDrawer({
    Key? key,
    required this.title,
    required this.onHomeTap,
    required this.onLoginTap,
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
            leading: Icon(
              // ignore: deprecated_member_use
              FontAwesomeIcons.signInAlt,
              size: 20,
            ),
            title: Text('Login'),
            horizontalTitleGap: 5,
            onTap: onLoginTap,
          ),
          ListTile(
            leading: Icon(
              // ignore: deprecated_member_use
              FontAwesomeIcons.homeAlt,
              size: 20,
            ),
            title: Text('Home'),
            horizontalTitleGap: 5,
            onTap: onHomeTap,
          ),
          ListTile(
            leading: Icon(
              // ignore: deprecated_member_use
              FontAwesomeIcons.cog,
              size: 20,
            ),
            title: Text('Settings'),
            horizontalTitleGap: 5,
            onTap: onSettingsTap,
          ),
          ListTile(
            leading: Icon(
              // ignore: deprecated_member_use
              FontAwesomeIcons.user,
              size: 20,
            ),
            title: Text('User'),
            horizontalTitleGap: 5,
            onTap: onUserTap,
          ),
        ],
      ),
    );
  }
}
