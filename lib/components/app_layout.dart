import 'package:flutter/material.dart';

import 'custom_drawer.dart'; // Assuming you have a custom drawer widget

class AppLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const AppLayout({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          title,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      endDrawer: CustomDrawer(
        title: 'My Ebooks',
        onLoginTap: () {
          Navigator.pushNamed(context, '/login');
        },
        onHomeTap: () {
          Navigator.pushNamed(context, '/home');
        },
        onSettingsTap: () {
          Navigator.pushNamed(context, '/settings');
        },
        onUserTap: () {
          Navigator.pushNamed(context, '/user');
        },
      ),
      body: body, // Pass the body widget as content for the page
      bottomNavigationBar: Theme.of(context).useMaterial3
          ? NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (int index) {
                // Handle navigation based on the selected index
                switch (index) {
                  case 0:
                    // Navigate to the home page
                    break;
                  case 1:
                    // Navigate to the ebooks page
                    break;
                  case 2:
                    // Navigate to the settings page
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book),
                  label: 'Ebooks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            )
          : null,
    );
  }
}
