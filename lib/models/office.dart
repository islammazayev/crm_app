import '../utils/balances.dart';

class OfficePaymentMethod {
  final String id;
  final String label;
  final String details;
  final List<String> supportedFromCurrencies;

  OfficePaymentMethod({
    required this.id,
    required this.label,
    required this.details,
    required this.supportedFromCurrencies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'details': details,
      'supportedFromCurrencies': supportedFromCurrencies,
    };
  }

  factory OfficePaymentMethod.fromMap(Map<String, dynamic> map) {
    return OfficePaymentMethod(
      id: (map['id'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      details: (map['details'] ?? '').toString(),
      supportedFromCurrencies:
          (map['supportedFromCurrencies'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}

class Office {
  final String id;
  final String country;
  final String city;
  final List<String> currencies;
  final Map<String, double> balances;
  final String? managerUserId;
  final List<OfficePaymentMethod> paymentMethods;

  Office({
    required this.id,
    required this.country,
    required this.city,
    required this.currencies,
    required this.balances,
    this.managerUserId,
    required this.paymentMethods,
  });

  double balanceFor(String currency) => balances[currency] ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'city': city,
      'currencies': currencies,
      'balances': balances,
      'managerUserId': managerUserId,
      'paymentMethods': paymentMethods.map((e) => e.toMap()).toList(),
    };
  }

  factory Office.fromMap(String id, Map<String, dynamic> map) {
    return Office(
      id: id,
      country: (map['country'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      currencies: (map['currencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      balances: parseBalances(map['balances'], officeId: id),
      managerUserId: map['managerUserId']?.toString(),
      paymentMethods: (map['paymentMethods'] as List? ?? [])
          .map((e) => OfficePaymentMethod.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
