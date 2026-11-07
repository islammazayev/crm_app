import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/utils/countries.dart';
import 'package:crm_app/utils/search_match.dart';
import 'package:crm_app/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePhone/composePhone', () {
    test('svenskt nummer med nolla blir +46', () {
      expect(composePhone(countryByIso('SE'), '070-123 45 67'), '+46701234567');
    });
    test('tomt nummer blir tom text', () {
      expect(composePhone(countryByIso('SE'), ' '), '');
    });
    test('delar upp nummer med landskod', () {
      final p = parsePhone('+46701234567')!;
      expect(p.country.iso, 'SE');
      expect(p.national, '701234567');
      expect(parsePhone('+79281234567')!.country.iso, 'RU');
      expect(parsePhone('+905321234567')!.country.iso, 'TR');
      expect(parsePhone('+358401234567')!.country.iso, 'FI');
    });
    test('gamla nummer utan landskod tolkas inte', () {
      expect(parsePhone('0701234567'), isNull);
    });
  });

  test('sökning på 070… hittar +4670…', () {
    expect(matchesSearch('0701', phones: ['+46701234567']), isTrue);
    expect(matchesSearch('0731', phones: ['+46701234567']), isFalse);
  });

  Widget app(TextEditingController c) => MaterialApp(
    locale: const Locale('sv'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PhoneField(
        controller: c,
        decoration: const InputDecoration(labelText: 'Telefon'),
      ),
    ),
  );

  testWidgets('skriver hela numret med landskod', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(app(c));
    expect(find.textContaining('+46'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '0701234567');
    expect(c.text, '+46701234567');
  });

  testWidgets('byta land ändrar numret', (tester) async {
    final c = TextEditingController(text: '+46701234567');
    await tester.pumpWidget(app(c));
    await tester.tap(find.textContaining('+46'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Turkey');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Turkey').first);
    await tester.pumpAndSettle();
    expect(c.text, '+90701234567');
  });

  testWidgets('gammalt nummer visas som det är och ändras inte', (
    tester,
  ) async {
    final c = TextEditingController(text: '0701234567');
    await tester.pumpWidget(app(c));
    expect(find.text('0701234567'), findsOneWidget);
    expect(c.text, '0701234567');
  });

  testWidgets('tömd controller tömmer fältet', (tester) async {
    final c = TextEditingController(text: '+46701234567');
    await tester.pumpWidget(app(c));
    c.clear();
    await tester.pump();
    expect(find.text('701234567'), findsNothing);
  });
}
