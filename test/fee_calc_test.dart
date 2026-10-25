import 'package:crm_app/utils/fee_calc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sändning: avgiften dras från det kunden betalar', () {
    final a = ExchangeAmounts.fromPaid(
      amountFrom: 1000,
      feePercent: 5,
      rate: 0.1,
    );
    expect(a.feeAmountFrom, 50);
    expect(a.amountToGross, closeTo(100, 1e-9));
    expect(a.amountToNet, closeTo(95, 1e-9));
    expect(a.feeAmountTo, closeTo(5, 1e-9));
  });

  test('köp: kunden får exakt det hen köper och betalar avgiften', () {
    final a = ExchangeAmounts.forBuy(buyAmount: 95, feePercent: 5, rate: 0.1);
    expect(a.amountToNet, 95);
    expect(a.amountFrom, closeTo(1000, 0.01));
    expect(a.feeAmountFrom, closeTo(50, 0.01));
  });

  test('köp avrundas uppåt till hela ören', () {
    final a = ExchangeAmounts.forBuy(
      buyAmount: 100,
      feePercent: 4,
      rate: 0.087,
    );
    expect(a.amountFrom * 100, closeTo((a.amountFrom * 100).round(), 1e-6));
    // Det kunden betalar räcker alltid till beloppet efter avgift.
    expect((a.amountFrom * 0.96) * 0.087, greaterThanOrEqualTo(100 - 1e-9));
  });
}
