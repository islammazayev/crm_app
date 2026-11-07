import 'package:crm_app/customer/screens/customer_register_screen.dart';
import 'package:crm_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kunden skriver e-post och lösenord två gånger; olika värden stoppas
/// innan något konto skapas.
void main() {
  Future<void> fill(
    WidgetTester tester, {
    required String email2,
    required String password2,
  }) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('sv'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CustomerRegisterScreen(),
      ),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Islam');
    await tester.enterText(fields.at(1), 'Mazayev');
    await tester.enterText(fields.at(2), 'islam@gmail.com');
    await tester.enterText(fields.at(3), email2);
    await tester.enterText(fields.at(4), '123456789');
    await tester.enterText(fields.at(5), 'hemligt1');
    await tester.enterText(fields.at(6), password2);
    await tester.tap(find.text('Registrera'));
    await tester.pump();
  }

  testWidgets('olika e-post och lösenord visar fel', (tester) async {
    await fill(tester, email2: 'islam@gmial.com', password2: 'hemligt2');
    expect(find.text('E-postadresserna är inte lika.'), findsOneWidget);
    expect(find.text('Lösenorden är inte lika.'), findsOneWidget);
  });

  testWidgets('e-post med andra stora bokstäver räknas som olika', (
    tester,
  ) async {
    await fill(tester, email2: 'Islam@Gmail.com', password2: 'hemligt1');
    expect(find.text('E-postadresserna är inte lika.'), findsOneWidget);
  });

  testWidgets('exakt lika värden godtas', (tester) async {
    await fill(tester, email2: 'islam@gmail.com', password2: 'hemligt1');
    expect(find.text('E-postadresserna är inte lika.'), findsNothing);
    expect(find.text('Lösenorden är inte lika.'), findsNothing);
  });

  testWidgets('ögat visar och döljer lösenordet', (tester) async {
    await fill(tester, email2: 'islam@gmail.com', password2: 'hemligt1');
    bool hidden(int i) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byType(TextFormField).at(i),
            matching: find.byType(EditableText),
          ),
        )
        .obscureText;
    expect(hidden(5), isTrue);
    expect(hidden(6), isTrue);
    await tester.tap(find.byTooltip('Visa lösenord').first);
    await tester.pump();
    expect(hidden(5), isFalse);
    expect(hidden(6), isTrue);
  });

  testWidgets('registreringen klarar extra stor text på smal mobil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3 * 1.2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await fill(tester, email2: 'islam@gmail.com', password2: 'hemligt1');
    expect(tester.takeException(), isNull);
  });
}
