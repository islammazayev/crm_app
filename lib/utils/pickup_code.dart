import 'dart:math';

final _random = Random.secure();

/// Ny uthämtningskod, åtta siffror i två grupper: "4821-7730".
String newPickupCode() {
  String four() => _random.nextInt(10000).toString().padLeft(4, '0');
  return '${four()}-${four()}';
}

/// Jämför en inskriven kod med den riktiga. Mellanslag och bindestreck
/// spelar ingen roll, så "48217730" och "4821 7730" godtas också.
bool pickupCodeMatches(String entered, String code) {
  String digits(String s) => s.replaceAll(RegExp(r'\D'), '');
  final e = digits(entered);
  return e.isNotEmpty && e == digits(code);
}
