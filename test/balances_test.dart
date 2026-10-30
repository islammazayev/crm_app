import 'package:crm_app/utils/balances.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kontorets och kassörernas saldon läggs ihop per valuta', () {
    final total = sumBalances([
      {'RUB': 9136942.24, 'USDT': 4989056.78},
      {'RUB': 250000, 'USDT': 25000},
      {'EUR': 100},
    ]);
    expect(total['RUB'], closeTo(9386942.24, 1e-6));
    expect(total['USDT'], closeTo(5014056.78, 1e-6));
    expect(total['EUR'], 100);
  });

  test('inga saldon ger tom total', () {
    expect(sumBalances([]), isEmpty);
  });
}
