import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/widgets/admin_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Admin-listan: sök, snabbfilter, sidor om 20 och raderna utan overflow.
void main() {
  final names = [
    for (var i = 1; i <= 45; i++) 'Kund ${i.toString().padLeft(2, '0')}',
  ];

  Widget app({
    int? filter,
    ValueChanged<int?>? onFilter,
    double width = 1000,
  }) => MaterialApp(
    locale: const Locale('sv'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: AdminList<String>(
              items: names,
              searchHint: 'Sök',
              emptyText: 'Inga träffar',
              matches: (n, q) => n.contains(q),
              filters: [AdminFilter('Jämna', (n) => n.endsWith('0'))],
              filter: filter,
              onFilter: onFilter ?? (_) {},
              rowBuilder: (n) => AdminRow(
                avatar: AdminAvatar(name: n),
                title: n,
                subtitle: 'ID 001 · senast 7 nov. 2026',
                columns: const ['+46 70 123 45 67', 'Sverige Stockholm'],
                pill: const AdminPill(
                  'Ett mycket långt statusnamn',
                  Colors.green,
                ),
                actions: [AdminAction('Ändra', Icons.edit, () {})],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('visar 20 per sida och bläddrar', (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    expect(find.text('Kund 01'), findsOneWidget);
    expect(find.text('Kund 21'), findsNothing);
    expect(find.text('Visar 1–20 av 45'), findsOneWidget);
    await tester.tap(find.byTooltip('Nästa sida'));
    await tester.pump();
    expect(find.text('Kund 21'), findsOneWidget);
    expect(find.text('Visar 21–40 av 45'), findsOneWidget);
  });

  testWidgets('sök och filter begränsar listan', (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'Kund 4');
    await tester.pump();
    expect(find.text('Visar 1–6 av 6'), findsOneWidget);

    await tester.pumpWidget(app(filter: 0));
    await tester.pump();
    expect(find.text('Kund 40'), findsOneWidget);
    expect(find.text('Kund 41'), findsNothing);
  });

  testWidgets('chipet anropar onFilter', (tester) async {
    int? picked = -1;
    await tester.pumpWidget(app(onFilter: (i) => picked = i));
    await tester.tap(find.text('Jämna'));
    expect(picked, 0);
  });

  for (final width in [320.0, 375.0, 700.0, 1400.0]) {
    testWidgets('rader ritas utan overflow i bredd $width', (tester) async {
      tester.view.physicalSize = Size(width, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(width: width));
      expect(tester.takeException(), isNull);
    });
  }
}
