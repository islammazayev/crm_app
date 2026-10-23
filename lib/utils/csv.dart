/// Bygger CSV-text (RFC 4180): fält med komma, citattecken eller radbrytning
/// omges av citattecken, och citattecken i fältet dubbleras.
String toCsv(List<List<String>> rows) {
  String field(String v) {
    if (v.contains(RegExp(r'[",\r\n]'))) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  return rows.map((r) => r.map(field).join(',')).join('\r\n');
}
