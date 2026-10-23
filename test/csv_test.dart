import 'package:crm_app/utils/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vanliga fält skrivs som de är', () {
    expect(toCsv([['a', 'b'], ['1', '2']]), 'a,b\r\n1,2');
  });
  test('komma, citattecken och radbrytning citeras', () {
    expect(toCsv([['a,b', 'säger "hej"', 'rad1\nrad2']]),
        '"a,b","säger ""hej""","rad1\nrad2"');
  });
}
