import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const _host   = 'api.freecurrencyapi.com';
  static const _path   = '/v1/latest';
  static const _apiKey = 'fca_live_ovmlfuE66Q6NXaw1m8uLfwMUozIyITmqkdFMGg1W';

  static String _normalizeCurrency(String c) {
    c = c.toUpperCase().trim();
    if (c == 'USDT') return 'USD';  // mappa krypto till fiat för API:t
    if (c == 'RUBLE') return 'RUB'; // din app-text → riktig ISO-kod
    if (c == 'EURO') return 'EUR';
    return c;
  }

  /// Hämtar kurs från [from] till [to], t.ex. from: 'USDT', to: 'RUBLE'.
  static Future<double> getRate(String from, String to) async {
    final apiFrom = _normalizeCurrency(from);
    final apiTo   = _normalizeCurrency(to);

    final uri = Uri.https(_host, _path, {
      'apikey': _apiKey,
      'base_currency': apiFrom,
      'currencies': apiTo,
    });

    final res = await http.get(uri);
    print('GET $uri -> ${res.statusCode}, body=${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Kunde inte hämta växelkurs: ${res.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(res.body);
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    final num? value = data[apiTo] as num?;

    if (value == null) {
      throw Exception('Ingen kurs $apiFrom → $apiTo');
    }

    return value.toDouble();
  }

}
