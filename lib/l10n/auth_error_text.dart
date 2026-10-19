import 'package:firebase_auth/firebase_auth.dart';

import 'app_localizations.dart';

/// Översätter de vanligaste inloggnings- och registreringsfelen.
/// Okända fel visas med Firebase eget meddelande.
String authErrorText(AppLocalizations l10n, Object error) {
  if (error is! FirebaseAuthException) return l10n.errorWithDetails('$error');
  switch (error.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return l10n.authWrongCredentials;
    case 'invalid-email':
      return l10n.authInvalidEmail;
    case 'email-already-in-use':
      return l10n.authEmailInUse;
    case 'weak-password':
      return l10n.authWeakPassword;
    case 'missing-email':
      return l10n.authMissingEmail;
    case 'too-many-requests':
      return l10n.authTooManyRequests;
    case 'network-request-failed':
      return l10n.authNetworkError;
    case 'user-disabled':
      return l10n.authUserDisabled;
    default:
      return l10n.errorWithDetails(error.message ?? error.code);
  }
}
