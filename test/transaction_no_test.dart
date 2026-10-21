import 'package:crm_app/utils/search_match.dart';
import 'package:crm_app/utils/transaction_no.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('format', () {
    expect(formatTransactionNo(12), 'T-00012');
    expect(formatTransactionNo('7'), 'T-00007');
    expect(formatTransactionNo(123456), 'T-123456');
    expect(formatTransactionNo(null), '');
    expect(formatTransactionNo('abc'), '');
  });

  test('sökning på transaktionsnummer', () {
    bool tx(String q, int no) => matchesSearch(
          q,
          ids: ['$no', formatTransactionNo(no).replaceFirst('T-', '')],
          texts: [formatTransactionNo(no)],
        );
    expect(tx('T-00012', 12), isTrue);
    expect(tx('t-00012', 12), isTrue);
    expect(tx('12', 12), isTrue);
    expect(tx('00012', 12), isTrue);
    expect(tx('0001', 12), isTrue);
    expect(tx('13', 12), isFalse);
  });
}
