import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared colour palette for the Velora admin screens.
///
/// One accent (brass) is spent deliberately on primary actions and active
/// states; everything else stays quiet ink-on-canvas so tables and forms
/// stay legible.
class AdminColors {
  AdminColors._();

  static const ink = Color(0xFF211B2E);
  static const inkSoft = Color(0xFF372F49);
  static const muted = Color(0xFF6B6775);
  static const line = Color(0xFFE7E4EE);
  static const canvas = Color(0xFFF5F4F8);
  static const surface = Color(0xFFFFFFFF);

  static const brass = Color(0xFFA6813C);
  static const brassDark = Color(0xFF8C6C2F);
  static const brassTint = Color(0xFFF4ECDA);

  static const success = Color(0xFF2F7A4F);
  static const successTint = Color(0xFFE4F2E9);
  static const danger = Color(0xFFB3441E);
  static const dangerTint = Color(0xFFFBEAE3);
  static const warn = Color(0xFF9A6A17);
  static const warnTint = Color(0xFFFBF1DD);

  static const swatches = <Color>[
    Color(0xFF4E4468),
    Color(0xFF7A5C3E),
    Color(0xFF3E6B57),
    Color(0xFF7A4B57),
    Color(0xFF4B5E7A),
    Color(0xFF6B5A80),
    Color(0xFF8C6C2F),
    Color(0xFF3F5A4E),
  ];

  /// Deterministic colour for a product/category thumbnail swatch, so the
  /// same name always gets the same colour without needing real photography.
  static Color swatchFor(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) % swatches.length;
    }
    return swatches[hash.abs() % swatches.length];
  }
}

/// Two families used deliberately: Fraunces for screen titles and drawer/
/// dialog headings (a little editorial warmth for a fashion-forward brand),
/// Inter for everything data-dense — tables, forms, nav, labels.
class AdminText {
  AdminText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AdminColors.ink,
  }) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AdminColors.ink,
  }) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
}

/// Small helper for initials shown inside a colour swatch when there's no
/// product/category photo yet.
String initialsFor(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
