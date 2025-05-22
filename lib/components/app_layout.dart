import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const AppLayout({Key? key, required this.title, required this.body})
      : super(key: key);

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
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: body,
        ),
      ),
      bottomNavigationBar: Theme.of(context).useMaterial3
          ? NavigationBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
        height: 60,
        indicatorColor: Colors.blue.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: 0,
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/ebooks');
              break;
            case 2:
              Navigator.pushNamed(context, '/user');
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
