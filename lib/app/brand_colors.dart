import 'package:flutter/material.dart';

/// Obmind brand palette derived from the app icon.
abstract final class BrandColors {
  /// Warm cream paper background.
  static const cream = Color(0xFFF5F0E6);

  /// Slightly lighter cream for elevated surfaces.
  static const creamElevated = Color(0xFFFAF7F0);

  /// Dark mode paper background.
  static const creamDark = Color(0xFF1E1C1A);

  /// Dark mode elevated surface.
  static const creamDarkElevated = Color(0xFF2A2724);

  /// Soft salmon accent.
  static const salmon = Color(0xFFE5A08E);

  /// Warm mustard accent.
  static const mustard = Color(0xFFD4B86A);

  /// Soft sage accent.
  static const sage = Color(0xFF9DB89A);

  /// Primary text on cream.
  static const onCream = Color(0xFF3A3530);

  /// Secondary text on cream.
  static const onCreamMuted = Color(0xFF6B645C);

  /// Light text on dark surfaces.
  static const onCreamDark = Color(0xFFE8E4DC);

  /// Muted text on dark surfaces.
  static const onCreamDarkMuted = Color(0xFFA8A29A);
}
