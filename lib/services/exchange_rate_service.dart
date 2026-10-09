import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const _host   = 'api.freecurrencyapi.com';
  static const _path   = '/v1/latest';
  /// API-nyckeln ligger inte i koden. Starta/bygg appen med:
  ///   flutter run --dart-define=FX_API_KEY=din_nyckel
  static const _apiKey = String.fromEnvironment('FX_API_KEY');

  static String _normalizeCurrency(String c) {
    c = c.toUpperCase().trim();
    if (c == 'USDT') return 'USD';  // mappa krypto till fiat för API:t
    if (c == 'RUBLE') return 'RUB'; // din app-text → riktig ISO-kod
    if (c == 'EURO') return 'EUR';
    return c;
  }

  /// Hämtar kurs från [from] till [to], t.ex. from: 'USDT', to: 'RUBLE'.
  static Future<double> getRate(String from, String to) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'FX_API_KEY saknas. Starta appen med --dart-define=FX_API_KEY=...',
      );
    }

    final apiFrom = _normalizeCurrency(from);
    final apiTo   = _normalizeCurrency(to);

    final uri = Uri.https(_host, _path, {
      'apikey': _apiKey,
      'base_currency': apiFrom,
      'currencies': apiTo,
    });

    final res = await http.get(uri);

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
