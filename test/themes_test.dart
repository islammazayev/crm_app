import 'package:crm_app/l10n/app_localizations.dart';
import 'package:crm_app/theme/app_palettes.dart';
import 'package:crm_app/theme/app_theme.dart';
import 'package:crm_app/theme/theme_controller.dart';
import 'package:crm_app/widgets/app_shell.dart';
import 'package:crm_app/widgets/overview_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Varje tema ska rita appen utan fel och faktiskt byta färger.
void main() {
  tearDown(() => ThemeController.instance.value = AppPalette.greentex);

  Widget app() => MaterialApp(
    theme: AppTheme.current,
    locale: const Locale('sv'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppShell(
      destinations: [
        ShellDestination(
          icon: Icons.home,
          label: 'Översikt',
          builder: (_) => const OverviewPage(
            title: 'God morgon, Adam',
            children: [
              BalanceHero(title: 'Totalt saldo', balances: {'EUR': 1000}),
            ],
          ),
        ),
      ],
    ),
  );

  test('fem teman med olika id', () {
    expect(AppPalette.all.length, 5);
    expect(AppPalette.all.map((p) => p.id).toSet().length, 5);
    expect(AppPalette.byId('okänt'), AppPalette.greentex);
  });

  for (final palette in AppPalette.all) {
    for (final width in [375.0, 1400.0]) {
      testWidgets('${palette.id} ritas utan fel i bredd $width', (
        tester,
      ) async {
        ThemeController.instance.value = palette;
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final context = tester.element(find.byType(OverviewPage));
        expect(Theme.of(context).colorScheme.primary, palette.primary);
        expect(Theme.of(context).brightness, palette.brightness);
        expect(AppColors.primaryDim, palette.primaryDim);
      });
    }
  }
}
