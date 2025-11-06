// lib/components/app_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ebook_project/components/under_maintanance_snackbar.dart';
import 'custom_drawer.dart';

/// ------------------------------
/// App primary gradient (blue 600 → 800)
/// ------------------------------
LinearGradient appPrimaryGradient() => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.blue.shade600,
    Colors.blue.shade800,
  ],
);

/// ------------------------------
/// GradientIcon: active হলে গ্রেডিয়েন্ট রঙ, না হলে স্লেট টোন
/// ------------------------------
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final double size;

  const GradientIcon(
      this.icon, {
        super.key,
        required this.active,
        this.size = 24,
      });

  @override
  Widget build(BuildContext context) {
    if (!active) {
      // Inactive → neutral/slate tone
      return Icon(icon, size: size, color: const Color(0xFF64748B)); // slate-500
    }
    // Active → gradient fill
    return ShaderMask(
      shaderCallback: (rect) => appPrimaryGradient().createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

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
      // ===== AppBar: simple + consistent gradient =====
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
          decoration: BoxDecoration(gradient: appPrimaryGradient()),
        ),
      ),

      // ===== Drawer =====
      endDrawer: showDrawer
          ? CustomDrawer(
        title: 'My Ebooks',
        onLoginTap:   () => Navigator.pushNamed(context, '/login'),
        onHomeTap:    () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        onSettingsTap:() => Navigator.pushNamed(context, '/settings'),
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
      )
          : null,

      // ===== Body =====
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: body,
        ),
      ),

      // ===== Bottom Navigation (Material convention) =====
      // কোনো অতিরিক্ত ব্যাকগ্রাউন্ড/কন্টেইনার নেই
      bottomNavigationBar: showNavBar
          ? NavigationBar(
        backgroundColor: Colors.transparent, // surface-এ মিশে যায়
        height: 64,
        elevation: 0,
        indicatorColor: Colors.blue.shade600.withOpacity(0.12), // subtle
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selected,
        onDestinationSelected: (index) {
          if (index == selected) return;
          HapticFeedback.selectionClick();

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
        destinations: [
          NavigationDestination(
            icon: GradientIcon(Icons.home_rounded, active: false, size: 24),
            selectedIcon: GradientIcon(Icons.home_rounded, active: true, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: GradientIcon(Icons.library_books_rounded, active: false, size: 24),
            selectedIcon: GradientIcon(Icons.library_books_rounded, active: true, size: 24),
            label: 'Library',
          ),
          NavigationDestination(
            icon: GradientIcon(Icons.account_circle_rounded, active: false, size: 24),
            selectedIcon: GradientIcon(Icons.account_circle_rounded, active: true, size: 24),
            label: 'Profile',
          ),
        ],
      )
          : null,
    );
  }
}
