import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/brand_colors.dart';
import 'package:obmind/app/obmind_theme.dart';

void main() {
  group('ObmindTheme', () {
    test('light scheme uses brand cream surface and accents', () {
      final scheme = ObmindTheme.lightColorScheme;

      expect(scheme.surface, BrandColors.cream);
      expect(scheme.primary, BrandColors.salmon);
      expect(scheme.secondary, BrandColors.mustard);
      expect(scheme.tertiary, BrandColors.sage);
      expect(scheme.onSurface, BrandColors.onCream);
    });

    test('dark scheme uses brand dark cream surface', () {
      final scheme = ObmindTheme.darkColorScheme;

      expect(scheme.surface, BrandColors.creamDark);
      expect(scheme.onSurface, BrandColors.onCreamDark);
    });

    test('light and dark themes build without error', () {
      expect(ObmindTheme.light().useMaterial3, isTrue);
      expect(ObmindTheme.dark().useMaterial3, isTrue);
    });
  });
}
