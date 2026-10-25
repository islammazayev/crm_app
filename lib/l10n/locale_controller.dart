import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Håller appens språk. `null` betyder att enhetens språk används.
///
/// Valet sparas på enheten, så appen öppnas på samma språk nästa gång.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);

  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale';

  /// Används när enhetens språk inte finns i appen.
  static const fallback = Locale('ru');

  /// Språken i den ordning de visas i språkväljaren, med sitt eget namn.
  static const languages = <String, String>{
    'ru': 'Русский',
    'en': 'English',
    'sv': 'Svenska',
    'tr': 'Türkçe',
  };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && languages.containsKey(code)) {
        value = Locale(code);
      }
    } catch (_) {
      // Utan sparat val används enhetens språk.
    }
  }

  /// Sätter språket. `null` går tillbaka till enhetens språk.
  Future<void> setLocale(Locale? locale) async {
    value = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, locale.languageCode);
      }
    } catch (_) {
      // Valet gäller ändå tills appen stängs.
    }
  }

  /// Väljer första av enhetens språk som appen har, annars [fallback].
  static Locale resolve(List<Locale>? deviceLocales, Iterable<Locale> supported) {
    for (final device in deviceLocales ?? const <Locale>[]) {
      for (final s in supported) {
        if (s.languageCode == device.languageCode) return s;
      }
    }
    return fallback;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
