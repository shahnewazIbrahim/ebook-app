import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ebook_project/api/routes.dart';

class CustomDrawer extends StatefulWidget {
  final String title;
  final VoidCallback onHomeTap;
  final VoidCallback onLoginTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  const CustomDrawer({
    Key? key,
    required this.title,
    required this.onHomeTap,
    required this.onLoginTap,
    required this.onSettingsTap,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await http.post(
          getFullUrl('/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Clear local storage
          await prefs.clear();

          // Navigate to login
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else {
          print("Logout failed: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              // child: Text(
              //   widget.title,
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Image.asset(
                  'assets/bm-logo-white.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // if(currentRoute != '/')
            buildDrawerItem(
              icon: FontAwesomeIcons.homeAlt,
              label: 'Home',
              onTap: currentRoute != '/' ? widget.onHomeTap : () {},
              route : '/'
            ),
          // if(currentRoute != '/profile')
            buildDrawerItem(
              icon: FontAwesomeIcons.user,
              label: 'User',
              onTap: currentRoute != '/profile' ? widget.onProfileTap : () {},
              route : '/profile'
            ),
          buildDrawerItem(
            icon: FontAwesomeIcons.cog,
            label: 'Settings',
            onTap: widget.onSettingsTap,
          ),
          if (!isLoggedIn)
            buildDrawerItem(
              icon: FontAwesomeIcons.signInAlt,
              label: 'Login',
              onTap: widget.onLoginTap,

            ),
          if (isLoggedIn)
            buildDrawerItem(
              icon: FontAwesomeIcons.signOutAlt,
              label: 'Logout',
              onTap: () => logout(context),
            ),
        ],
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? route
  }) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    bool isSelected = (route != null && route == currentRoute);
    return ListTile(
      leading: Icon(
          icon,
          size: 20,
          // color: Colors.blue[700]
          color: isSelected ? Colors.white : Colors.blue[700],
      ),
      title: Text(
        label,
        style:  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: isSelected ? Colors.blue[700] : null,
      onTap: onTap,
    );
  }
}
