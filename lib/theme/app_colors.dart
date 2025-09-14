import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF3B82F6); // Blue 500
  static const Color secondary = Color(0xFF6366F1); // Indigo 500
  static const Color accent = Color(0xFF10B981); // Emerald 500

  // Neutrals
  static const Color bg = Color(0xFFF8FAFC); // very light
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600

  // Inputs
  static const Color inputFill = Colors.white;
  static const Color inputBorder = Color(0xFFE5E7EB); // Slate 200
  static const Color inputFocus = primary;

  // Header / subtle gradients (low alpha)
  static const Color headerTintA = Color(0x143B82F6); // 8% of primary
  static const Color headerTintB = Color(0x106366F1); // 6% of secondary

  // NavBar
  static const Color navBg = Color(0xFFF2F4F8);
  static const Color navIndicator = Color(0x263B82F6); // 15% primary

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 10),
    ),
  ];

  // app_colors.dart (Add these)
  // Cards
  static const Color cardBorder = Color(0xFFE5E7EB); // subtle border

  // Chips
  static const Color chipActiveBg = Color(0xE616A34A); // success with opacity
  static const Color chipExpiredBg = Color(0xE6DC2626); // danger with opacity

  // Buttons (toned)
  static const Color btnRead = primary; // main action
  static const Color btnRenew = Color(0xFFEF4444); // red 500 (outlined/tonal)
  static const Color btnContinue = Color(0xFF6366F1); // indigo 500

// Pastel tints (50-range)
  static const Color cardTintNeutral = Color(0xFFF8FAFC); // Slate-50
  static const Color cardTintBlue = Color(0xFFEFF6FF); // Blue-50
  static const Color cardTintIndigo = Color(0xFFEEF2FF); // Indigo-50
  static const Color cardTintEmerald = Color(0xFFECFDF5); // Emerald-50
  static const Color cardTintAmber = Color(0xFFFFFBEB); // Amber-50
  static const Color cardTintRose = Color(0xFFFFF1F2); // Rose-50

  static const List<Color> cardTints = [
    cardTintNeutral,
    cardTintBlue,
    cardTintIndigo,
    cardTintEmerald,
    cardTintAmber,
    cardTintRose,
  ];

// সূক্ষ্ম সহায়তাকারী
  static Color cardTintByIndex(int i) => cardTints[i % cardTints.length];

  static Color cardTintByStatus(String status) =>
      status == 'Active' ? cardTintEmerald : cardTintRose;

  static const List<List<Color>> cardGradientSets = [
    [Color(0xFF3B82F6), Color(0xFF6366F1)], // blue → indigo
    [Color(0xFF10B981), Color(0xFF14B8A6)], // emerald → teal
    [Color(0xFFF59E0B), Color(0xFFF97316)], // amber → orange
    [Color(0xFF8B5CF6), Color(0xFFEC4899)], // violet → pink
    [Color(0xFF06B6D4), Color(0xFF3B82F6)], // cyan → blue
    [Color(0xFF22C55E), Color(0xFF16A34A)], // green shades
  ];

  static List<Color> cardGradientByIndex(int i) =>
      cardGradientSets[i % cardGradientSets.length];

// Text/controls on top of gradient
  static const Color onGradient = Colors.white;
  static const Color onGradientSoft = Color(0xE6FFFFFF); // 90% white

// Chips (on gradient)
  static const Color chipOnGradientBg = Color(0x33FFFFFF); // 20% white
  static const Color chipOnGradientBorder = Color(0x66FFFFFF); // 40% white
}
