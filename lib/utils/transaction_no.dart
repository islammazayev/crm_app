/// Visar ett transaktionsnummer på samma sätt överallt (12 → "T-00012").
/// Tom text om transaktionen inte har fått något nummer än.
String formatTransactionNo(Object? no) {
  final n = no is num ? no.toInt() : int.tryParse('${no ?? ''}'.trim());
  if (n == null) return '';
  return 'T-${n.toString().padLeft(5, '0')}';
}
