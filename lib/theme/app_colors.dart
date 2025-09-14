import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary   = Color(0xFF3B82F6); // Blue 500
  static const Color secondary = Color(0xFF6366F1); // Indigo 500
  static const Color accent    = Color(0xFF10B981); // Emerald 500

  // Neutrals
  static const Color bg            = Color(0xFFF8FAFC); // very light
  static const Color card          = Colors.white;
  static const Color textPrimary   = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600

  // Inputs
  static const Color inputFill   = Colors.white;
  static const Color inputBorder = Color(0xFFE5E7EB); // Slate 200
  static const Color inputFocus  = primary;

  // Header / subtle gradients (low alpha)
  static const Color headerTintA = Color(0x143B82F6); // 8% of primary
  static const Color headerTintB = Color(0x106366F1); // 6% of secondary

  // NavBar
  static const Color navBg       = Color(0xFFF2F4F8);
  static const Color navIndicator= Color(0x263B82F6); // 15% primary

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFDC2626);

  // Card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 10),
    ),
  ];
}
