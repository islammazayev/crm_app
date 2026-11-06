import 'package:crm_app/utils/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tusental skiljs med mellanrum', () {
    expect(formatMoney(16886942.24), '16 886 942.24');
    expect(formatMoney(999), '999.00');
    expect(formatMoney(1000, decimals: 0), '1 000');
    expect(formatMoney(0), '0.00');
  });

  test('negativa belopp', () {
    expect(formatMoney(-1500.5), '−1 500.50');
  });
}
