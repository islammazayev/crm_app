import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Menyn: sidomeny på bred skärm, bottenmeny med "Mer" på mobil.
void main() {
  var tappedAction = false;

  Widget page(String name) => Scaffold(
    appBar: AppBar(title: Text('Sida $name')),
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                Scaffold(appBar: AppBar(title: Text('Under $name'))),
          ),
        ),
        child: const Text('Öppna'),
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sv'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(
          mobileCount: 2,
          primaryAction: ShellAction(
            icon: Icons.add,
            label: 'Ny',
            onTap: () => tappedAction = true,
          ),
          destinations: [
            for (final (i, name) in const ['Ett', 'Två', 'Tre', 'Fyra'].indexed)
              ShellDestination(
                icon: Icons.home,
                label: name,
                badge: i == 1 ? 3 : 0,
                builder: (_) => page(name),
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('bred skärm: alla val i sidomenyn, utan bottenmeny', (
    tester,
  ) async {
    await pump(tester, 1200);
    for (final name in ['Ett', 'Två', 'Tre', 'Fyra']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.byTooltip('Mer'), findsNothing);

    await tester.tap(find.text('Tre'));
    await tester.pumpAndSettle();
    expect(find.text('Sida Tre'), findsOneWidget);
  });

  testWidgets('mobil: bottenmeny, och resten under Mer', (tester) async {
    await pump(tester, 375);
    expect(find.byTooltip('Ett'), findsOneWidget);
    expect(find.byTooltip('Tre'), findsNothing);
    expect(find.byTooltip('Ny'), findsOneWidget);

    await tester.tap(find.byTooltip('Ny'));
    expect(tappedAction, isTrue);

    await tester.tap(find.byTooltip('Mer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fyra'));
    await tester.pumpAndSettle();
    expect(find.text('Sida Fyra'), findsOneWidget);
  });

  testWidgets('menyn finns kvar på en undersida och val minns sin plats', (
    tester,
  ) async {
    await pump(tester, 1200);
    await tester.tap(find.text('Öppna').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Under Ett'), findsOneWidget);
    expect(find.text('Fyra'), findsOneWidget);

    await tester.tap(find.text('Två'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ett'));
    await tester.pumpAndSettle();
    expect(find.text('Under Ett'), findsOneWidget);

    // Tryck på samma val igen: tillbaka till valets början.
    await tester.tap(find.text('Ett'));
    await tester.pumpAndSettle();
    expect(find.text('Under Ett'), findsNothing);
    expect(find.text('Sida Ett'), findsOneWidget);
  });
}
