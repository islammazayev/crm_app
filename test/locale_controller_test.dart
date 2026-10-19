import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/l10n/locale_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  group('LocaleController.resolve', () {
    test('väljer enhetens språk när appen har det', () {
      expect(
        LocaleController.resolve(const [Locale('tr', 'TR')], supported),
        const Locale('tr'),
      );
      expect(
        LocaleController.resolve(const [Locale('sv', 'SE')], supported),
        const Locale('sv'),
      );
    });

    test('tar första språket i enhetens lista som appen har', () {
      expect(
        LocaleController.resolve(
          const [Locale('de'), Locale('en', 'US'), Locale('ru')],
          supported,
        ),
        const Locale('en'),
      );
    });

    test('faller tillbaka på ryska', () {
      expect(
        LocaleController.resolve(const [Locale('de', 'DE')], supported),
        const Locale('ru'),
      );
      expect(LocaleController.resolve(null, supported), const Locale('ru'));
    });
  });

  group('sparat språkval', () {
    test('sparas och läses tillbaka', () async {
      SharedPreferences.setMockInitialValues({});
      await LocaleController.instance.setLocale(const Locale('tr'));
      LocaleController.instance.value = null;
      await LocaleController.instance.load();
      expect(LocaleController.instance.value, const Locale('tr'));
    });

    test('enhetens språk tar bort det sparade valet', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      await LocaleController.instance.setLocale(null);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
    });
  });

  test('alla fyra språk finns', () {
    expect(
      supported.map((l) => l.languageCode).toSet(),
      {'ru', 'en', 'sv', 'tr'},
    );
  });
}
