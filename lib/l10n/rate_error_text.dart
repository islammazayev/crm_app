import '../services/exchange_rate_service.dart';
import 'app_localizations.dart';

/// Översätter fel från växelkurstjänsten. Andra fel visas som de är.
String rateErrorText(AppLocalizations l10n, Object error) {
  if (error is! ExchangeRateException) return '$error';
  switch (error.kind) {
    case ExchangeRateError.missingApiKey:
      return l10n.rateMissingApiKey;
    case ExchangeRateError.httpError:
      return l10n.rateHttpError(error.statusCode ?? 0);
    case ExchangeRateError.notFound:
      return l10n.rateNotFound(error.from, error.to);
  }
}
