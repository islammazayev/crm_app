class TransactionModel {
  final String sender;
  final String receiver;
  final String currency;
  final double amount;
  final double fee;
  final String country;
  final String city;
  final DateTime date;

  /// Fälten nedan finns bara på kundernas förfrågningar (nya flödet).
  /// Äldre poster saknar dem och får tomma värden.
  final String status; // t.ex. 'completed'
  final String label; // t.ex. "Klient 003 · Anna Svensson"
  final String toCurrency;

  TransactionModel({
    required this.sender,
    required this.receiver,
    required this.currency,
    required this.amount,
    required this.fee,
    required this.country,
    required this.city,
    required this.date,
    this.status = '',
    this.label = '',
    this.toCurrency = '',
  });

  /// Bara genomförda ordrar ger vinst. Äldre poster (utan status) räknas som
  /// genomförda.
  bool get isCompleted => status.isEmpty || status == 'completed';
}
