import 'package:flutter/material.dart';
import 'package:obmind/app/brand_colors.dart';

abstract final class ObmindTheme {
  static ThemeData light() {
    return _build(Brightness.light, lightColorScheme);
  }

  static ThemeData dark() {
    return _build(Brightness.dark, darkColorScheme);
  }

  static ColorScheme get lightColorScheme {
    final base = ColorScheme.fromSeed(
      seedColor: BrandColors.salmon,
      brightness: Brightness.light,
    );
    return base.copyWith(
      primary: BrandColors.salmon,
      onPrimary: BrandColors.onCream,
      primaryContainer: const Color(0xFFFCE8E3),
      onPrimaryContainer: BrandColors.onCream,
      secondary: BrandColors.mustard,
      onSecondary: BrandColors.onCream,
      secondaryContainer: const Color(0xFFF5EDD4),
      onSecondaryContainer: BrandColors.onCream,
      tertiary: BrandColors.sage,
      onTertiary: BrandColors.onCream,
      tertiaryContainer: const Color(0xFFE0EDDE),
      onTertiaryContainer: BrandColors.onCream,
      surface: BrandColors.cream,
      onSurface: BrandColors.onCream,
      onSurfaceVariant: BrandColors.onCreamMuted,
      surfaceContainerLowest: BrandColors.creamElevated,
      surfaceContainerLow: const Color(0xFFF0EBE2),
      surfaceContainer: const Color(0xFFEAE4DA),
      surfaceContainerHigh: const Color(0xFFE4DDD2),
      surfaceContainerHighest: const Color(0xFFDED7CC),
      outline: const Color(0xFFCCC4B8),
      outlineVariant: const Color(0xFFE0DAD0),
    );
  }

  static ColorScheme get darkColorScheme {
    final base = ColorScheme.fromSeed(
      seedColor: BrandColors.salmon,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      primary: BrandColors.salmon,
      onPrimary: BrandColors.creamDark,
      primaryContainer: const Color(0xFF5C3D35),
      onPrimaryContainer: const Color(0xFFFCE8E3),
      secondary: BrandColors.mustard,
      onSecondary: BrandColors.creamDark,
      secondaryContainer: const Color(0xFF4A4228),
      onSecondaryContainer: const Color(0xFFF5EDD4),
      tertiary: BrandColors.sage,
      onTertiary: BrandColors.creamDark,
      tertiaryContainer: const Color(0xFF354A38),
      onTertiaryContainer: const Color(0xFFE0EDDE),
      surface: BrandColors.creamDark,
      onSurface: BrandColors.onCreamDark,
      onSurfaceVariant: BrandColors.onCreamDarkMuted,
      surfaceContainerLowest: BrandColors.creamDarkElevated,
      surfaceContainerLow: const Color(0xFF322F2C),
      surfaceContainer: const Color(0xFF3A3633),
      surfaceContainerHigh: const Color(0xFF444038),
      surfaceContainerHighest: const Color(0xFF4E4A42),
      outline: const Color(0xFF6B6560),
      outlineVariant: const Color(0xFF444038),
    );
  }

  static ThemeData _build(Brightness brightness, ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? Colors.white
            : BrandColors.creamDarkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
