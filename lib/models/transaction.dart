class TransactionModel {
  final String sender;
  final String receiver;
  final String currency;
  final double amount;
  final double fee;
  final String country;
  final String city;

  TransactionModel({
    required this.sender,
    required this.receiver,
    required this.currency,
    required this.amount,
    required this.fee,
    required this.country,
    required this.city,
  });
}
