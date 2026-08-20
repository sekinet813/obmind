import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/app/app_locale_controller.dart';
import 'package:obmind/l10n/app_localizations.dart';

void main() {
  test('resolveAppLocale picks English when preferred', () {
    final resolved = resolveAppLocale(const [
      Locale('en', 'US'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('en'));
  });

  test('resolveAppLocale picks Japanese when preferred', () {
    final resolved = resolveAppLocale(const [
      Locale('ja'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('ja'));
  });

  test('resolveAppLocale falls back to Japanese for unsupported locales', () {
    final resolved = resolveAppLocale(const [
      Locale('fr'),
      Locale('de'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('ja'));
  });

  test('resolveAppLocale falls back when preferred list is empty', () {
    final resolved = resolveAppLocale(
      const [],
      AppLocalizations.supportedLocales,
    );
    expect(resolved, const Locale('ja'));
  });
}
