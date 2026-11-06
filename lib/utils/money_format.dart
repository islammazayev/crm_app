/// Belopp med mellanrum mellan tusental: 16886942.24 → "16 886 942.24".
String formatMoney(num value, {int decimals = 2}) {
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => ' ',
  );
  final sign = value < 0 ? '−' : '';
  return parts.length > 1 ? '$sign$grouped.${parts[1]}' : '$sign$grouped';
}
