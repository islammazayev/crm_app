import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/currencies.dart';

/// Fel från [ExchangeRateService]. Texten översätts i appen (se rateErrorText).
class ExchangeRateException implements Exception {
  final ExchangeRateError kind;
  final String from;
  final String to;
  final int? statusCode;

  const ExchangeRateException(
    this.kind, {
    this.from = '',
    this.to = '',
    this.statusCode,
  });

  @override
  String toString() => 'ExchangeRateException($kind, $from→$to, $statusCode)';
}

enum ExchangeRateError { missingApiKey, httpError, notFound }

class ExchangeRateService {
  static const _host = 'api.freecurrencyapi.com';
  static const _path = '/v1/latest';

  /// API-nyckeln ligger inte i koden. Starta/bygg appen med:
  ///   flutter run --dart-define-from-file=fx_key.json
  static const _apiKey = String.fromEnvironment('FX_API_KEY');

  static String _normalizeCurrency(String c) {
    c = normalizeCurrency(c);
    if (c == 'USDT') return 'USD'; // mappa krypto till fiat för API:t
    return c;
  }

  /// Hämtar kurs från [from] till [to], t.ex. from: 'USDT', to: 'RUBLE'.
  static Future<double> getRate(String from, String to) async {
    if (_apiKey.isEmpty) {
      throw const ExchangeRateException(ExchangeRateError.missingApiKey);
    }

    final apiFrom = _normalizeCurrency(from);
    final apiTo = _normalizeCurrency(to);

    final uri = Uri.https(_host, _path, {
      'apikey': _apiKey,
      'base_currency': apiFrom,
      'currencies': apiTo,
    });

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw ExchangeRateException(
        ExchangeRateError.httpError,
        statusCode: res.statusCode,
      );
    }

    final Map<String, dynamic> json = jsonDecode(res.body);
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    final num? value = data[apiTo] as num?;

    if (value == null) {
      throw ExchangeRateException(
        ExchangeRateError.notFound,
        from: apiFrom,
        to: apiTo,
      );
    }

    return value.toDouble();
  }
}
