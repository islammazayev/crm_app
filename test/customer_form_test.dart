import 'package:crm_app/forms/customer_form.dart';
import 'package:crm_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// SMS-valet visas bara när admin skriver klient-ID och telefon.
void main() {
  bool? sent;

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('sv'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: CustomerForm(
            onSubmit:
                ({
                  int? clientId,
                  required String firstName,
                  required String lastName,
                  required String phone,
                  String email = '',
                  bool sendInvite = false,
                }) async {
                  sent = sendInvite;
                },
          ),
        ),
      ),
    ),
  );

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('utan klient-ID syns inget SMS-val', (tester) async {
    await pump(tester);
    await tester.enterText(field('Telefon'), '0701234567');
    await tester.pump();
    expect(find.text('Skicka länk till appen (SMS)'), findsNothing);
  });

  testWidgets('klient-ID och telefon visar SMS-valet, ifyllt', (tester) async {
    sent = null;
    await pump(tester);
    await tester.enterText(field('Klient-ID (valfritt)'), '9');
    await tester.pump();
    expect(
      find.text(
        'Skriv kundens telefon om du vill skicka en länk till appen via SMS.',
      ),
      findsOneWidget,
    );
    await tester.enterText(field('Telefon'), '0701234567');
    await tester.enterText(field('Förnamn'), 'Ali');
    await tester.enterText(field('Efternamn'), 'K');
    await tester.pump();
    expect(find.text('Skicka länk till appen (SMS)'), findsOneWidget);
    await tester.tap(find.text('Spara kund'));
    await tester.pump();
    expect(sent, isTrue);
  });
}
