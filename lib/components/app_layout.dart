// lib/components/app_layout.dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ebook_project/components/under_maintanance_snackbar.dart';
import 'custom_drawer.dart';

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

  int _currentIndex(BuildContext context) {
    final name = ModalRoute.of(context)?.settings.name ?? '/';
    switch (name) {
      case '/': return 0;
      case '/ebooks': return 1;
      case '/profile': return 2;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _currentIndex(context);

    return Scaffold(
      // --- AppBar: exact blue gradient (600 → 800) ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light, // স্ট্যাটাসবার আইকন light
        title: Text(
          title,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
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
        ),
      ),

      // Drawer
      endDrawer: showDrawer
          ? CustomDrawer(
        title: 'My Ebooks',
        onLoginTap:   () => Navigator.pushNamed(context, '/login'),
        onHomeTap:    () => Navigator.pushNamed(context, '/'),
        onSettingsTap:() => Navigator.pushNamed(context, '/settings'),
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
      )
          : null,

      // Body
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: body,
        ),
      ),

      // --- Modern Glassy Bottom Navigation ---
      bottomNavigationBar: showNavBar
          ? Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                border: Border.all(color: Colors.white.withOpacity(0.65)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                height: 64,
                indicatorColor: Colors.blue.shade600.withOpacity(0.18),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: selected,
                onDestinationSelected: (index) {
                  if (index == selected) return;
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
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.library_books_outlined),
                    selectedIcon: Icon(Icons.library_books_rounded),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}
