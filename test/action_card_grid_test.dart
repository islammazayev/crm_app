import 'package:crm_app/widgets/action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Korten på startsidorna ska aldrig klippa text: varken på smal mobil
/// eller på bred skärm, och inte heller med långa (t.ex. ryska) texter.
void main() {
  const longText = 'Кассиры, привязанные к вам или вашему офису, с балансами '
      'и переводами. Отправленные и полученные переводы за всё время, '
      'с фильтрами и подробной информацией о каждом переводе.';

  Widget app(double width) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: width,
              child: ActionCardGrid(
                children: [
                  for (var i = 0; i < 5; i++)
                    ActionCard(
                      icon: Icons.point_of_sale,
                      iconColor: Colors.green,
                      title: 'Отправить деньги $i',
                      subtitle: i.isEven ? longText : 'Kort text',
                      badge: '$i',
                      onTap: () {},
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  for (final width in [320.0, 375.0, 800.0, 1000.0]) {
    testWidgets('lång text flödar inte över i bredd $width', (tester) async {
      tester.view.physicalSize = Size(width, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(width));
      expect(tester.takeException(), isNull);
      expect(find.byType(ActionCard), findsNWidgets(5));
      expect(find.text(longText), findsNWidgets(3));
    });
  }
}
