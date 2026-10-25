import 'package:crm_app/utils/customer_tiers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const settings = TierSettings(
    discounts: {
      CustomerTier.silver: 0.5,
      CustomerTier.gold: 1,
      CustomerTier.diamond: 2,
    },
  );

  test('nivåns rabatt dras från managerns avgift', () {
    final info = settings.forCustomer({'tier': 'gold'})!;
    expect(info.discount, 1);
    expect(info.feeAfterDiscount(5), 4);
    expect(info.feeAfterDiscount(8), 7);
    expect(info.feeAfterDiscount(0.5), 0);
    expect(info.toTransactionFields(), {
      'customerTier': 'gold',
      'tierDiscount': 1,
    });
  });

  test('egen rabatt går före nivåns', () {
    final info = settings.forCustomer({'tier': 'silver', 'tierDiscount': 1.5})!;
    expect(info.discount, 1.5);
    expect(info.isCustom, isTrue);
  });

  test('kund utan nivå får ingen rabatt', () {
    expect(settings.forCustomer({}), isNull);
    expect(settings.forCustomer({'tier': 'platinum'}), isNull);
  });

  test('standardvärden när admin inte har sparat något', () {
    final info = TierSettings.fromMap(null).forCustomer({'tier': 'diamond'})!;
    expect(info.discount, 1.5);
  });

  test('procent visas utan onödiga decimaler', () {
    expect(formatPercent(4), '4');
    expect(formatPercent(1.5), '1.5');
    expect(formatPercent(4.25), '4.25');
  });
}
