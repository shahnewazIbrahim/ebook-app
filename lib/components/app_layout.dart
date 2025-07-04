import 'package:ebook_project/components/under_maintanance_snackbar.dart';
import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'package:get/get.dart';


class AppLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDrawer;
  final bool showNavBar;

  const AppLayout({
    super.key,
    required this.title,
    required this.body,
    this.showDrawer = true,
    this.showNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        title: Text(
          title,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Drawer show or not
      endDrawer: showDrawer
          ? CustomDrawer(
        title: 'My Ebooks',
        onLoginTap: () {
          Navigator.pushNamed(context, '/login');
        },
        onHomeTap: () {
          Navigator.pushNamed(context, '/');
        },
        onSettingsTap: () {
          Navigator.pushNamed(context, '/settings');
        },
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
      )
          : null,

      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: body,
        ),
      ),

      // Bottom Navigation show or not
      bottomNavigationBar: showNavBar && Theme.of(context).useMaterial3
          ? NavigationBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
        height: 60,
        indicatorColor: Colors.blue.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: 0,
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              // Navigator.pushNamed(context, '/ebooks');
              showUnderMaintenanceSnackbar();
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Ebooks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      )
          : null,
    );
  }
}
