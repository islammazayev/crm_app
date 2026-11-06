import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/theme/app_theme.dart';
import 'package:crm_app/widgets/app_shell.dart';
import 'package:crm_app/widgets/overview_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Översiktens delar får inte flöda över, varken på mobil eller på dator,
/// och inte heller med långa texter eller stora belopp.
void main() {
  Widget app(Locale locale) => MaterialApp(
    locale: locale,
    theme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppShell(
      destinations: [
        ShellDestination(
          icon: Icons.home,
          label: 'Översikt',
          builder: (_) => OverviewPage(
            title: 'God morgon, Abdurrahman Abdurrahmanov',
            subtitle: 'Ryssland – Grozny',
            action: ElevatedButton(
              onPressed: () {},
              child: const Text('Ny transaktion'),
            ),
            children: [
              const BalanceHero(
                title: 'Totalt saldo',
                balances: {
                  'EUR': 571682.35,
                  'RUB': 16886942.24,
                  'USD': 65993.75,
                  'USDT': 4914056.78,
                  'SEK': 12.5,
                },
              ),
              const SizedBox(height: 12),
              const StatRow(
                stats: [
                  StatData('Väntar på svar från kund', '1', Colors.amber),
                  StatData('Klara att hämta', '5', Colors.blue),
                  StatData('Alla', '123', Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              ListPanel(
                title: 'Behöver dig nu',
                rows: [
                  StatusRow(
                    title: 'T-00015 · Abdurrahman Abdurrahmanov Abdurrahmanov',
                    subtitle: 'Köp 100000 EUR med RUB · Till min bank',
                    status: 'Betalning bekräftad av kontoret',
                    color: statusColor('payment_confirmed'),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        ShellDestination(
          icon: Icons.list,
          label: 'Transaktioner med ett långt namn',
          badge: 12,
          builder: (_) => const SizedBox(),
        ),
      ],
    ),
  );

  for (final width in [320.0, 375.0, 839.0, 840.0, 1400.0]) {
    testWidgets('inget flödar över i bredd $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(const Locale('sv')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Totalt saldo'), findsOneWidget);
      expect(find.textContaining('571 682 EUR'), findsOneWidget);
    });
  }

  testWidgets('översikten fyller hela skärmen bredvid menyn', (tester) async {
    tester.view.physicalSize = const Size(2000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const Locale('sv')));
    await tester.pumpAndSettle();
    // Skärm 2000, sidomeny 232, marginaler 2 x 20.
    expect(tester.getSize(find.byType(BalanceHero)).width, 2000 - 232 - 40);
    expect(tester.getTopLeft(find.byType(BalanceHero)).dx, 232 + 20);
  });

  test('hälsningen följer tiden på dygnet', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('sv'));
    expect(
      greetingFor(l10n, 'Adam', DateTime(2026, 1, 1, 8)),
      'God morgon, Adam',
    );
    expect(
      greetingFor(l10n, 'Adam', DateTime(2026, 1, 1, 13)),
      'God dag, Adam',
    );
    expect(
      greetingFor(l10n, 'Adam', DateTime(2026, 1, 1, 22)),
      'God kväll, Adam',
    );
  });
}
