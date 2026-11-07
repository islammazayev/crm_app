import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/widgets/add_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Lägg till"-knappen öppnar formuläret, och det stängs med krysset eller
/// när något har sparats.
void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('sv'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AddPanel(
          label: 'Lägg till kund',
          builder: (context, close) =>
              TextButton(onPressed: close, child: const Text('Spara kund')),
        ),
      ),
    ),
  );

  testWidgets('formuläret är stängt tills man trycker på knappen', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Spara kund'), findsNothing);
    await tester.tap(find.text('Lägg till kund'));
    await tester.pump();
    expect(find.text('Spara kund'), findsOneWidget);
    expect(find.text('Lägg till kund'), findsNothing);
  });

  testWidgets('krysset stänger formuläret', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Lägg till kund'));
    await tester.pump();
    await tester.tap(find.byTooltip('Avbryt'));
    await tester.pump();
    expect(find.text('Spara kund'), findsNothing);
    expect(find.text('Lägg till kund'), findsOneWidget);
  });

  testWidgets('formuläret stängs när något har sparats', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Lägg till kund'));
    await tester.pump();
    await tester.tap(find.text('Spara kund'));
    await tester.pump();
    expect(find.text('Spara kund'), findsNothing);
  });
}
