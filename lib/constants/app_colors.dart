import 'package:flutter/material.dart';

/// Velora brand tokens — taken from the reference theme
/// (indigo → violet primary, with pink / amber / emerald as status accents).
class VeloraColors {
  VeloraColors._();

  // Brand
  static const Color primary = Color(0xFF6366F1); // indigo
  static const Color secondary = Color(0xFF8B5CF6); // violet
  static const Color pink = Color(0xFFEC4899);
  static const Color amber = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);
  static const Color rose = Color(0xFFF43F5E); // danger / denied

  // Deep surfaces used by the navigation shell
  static const Color navyDeep = Color(0xFF13112C);
  static const Color navyMid = Color(0xFF1E1B4B);
  static const Color violetDeep = Color(0xFF2E1065);

  // Neutrals
  static const Color ink900 = Color(0xFF0F172A);
  static const Color ink700 = Color(0xFF334155);
  static const Color ink500 = Color(0xFF64748B);
  static const Color ink200 = Color(0xFFE2E8F0);
  static const Color ink100 = Color(0xFFF1F5F9);
  static const Color ink50 = Color(0xFFF8FAFC);

  /// Sidebar / nav surface.
  static const LinearGradient navGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navyMid, violetDeep],
    stops: [0.0, 0.55, 1.0],
  );

  /// Primary call-to-action + active state.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Light app background.
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ink50, ink200],
  );

  static List<BoxShadow> glow(Color color, {double opacity = 0.35}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
