/// Visar ett klient-ID på samma sätt överallt (1 → "001").
///
/// Klient-ID kan ligga som heltal (admin och nya registreringar) eller som
/// text (äldre registreringar, t.ex. "001"), så funktionen tar båda.
String formatClientId(Object? id) {
  final text = (id ?? '').toString().trim();
  if (text.isEmpty) return '';
  final n = int.tryParse(text);
  return n == null ? text : n.toString().padLeft(3, '0');
}
