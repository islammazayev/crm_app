import 'app_localizations.dart';

/// Transaktionens status som admin och manager ser den.
String statusText(AppLocalizations l10n, String status) {
  switch (status) {
    case 'customer_requested':
      return l10n.statusRequested;
    case 'manager_proposed':
      return l10n.statusProposed;
    case 'customer_accepted':
      return l10n.statusAccepted;
    case 'customer_countered':
      return l10n.statusCountered;
    case 'customer_rejected':
      return l10n.statusRejected;
    case 'completed':
      return l10n.statusCompleted;
    default:
      return status;
  }
}
