/// Belopp i en växling med avgift i procent av det kunden betalar.
class ExchangeAmounts {
  final double amountFrom;
  final double feeAmountFrom;
  final double amountToGross;
  final double amountToNet;
  final double feeAmountTo;

  const ExchangeAmounts({
    required this.amountFrom,
    required this.feeAmountFrom,
    required this.amountToGross,
    required this.amountToNet,
    required this.feeAmountTo,
  });

  /// Kunden betalar [amountFrom]; avgiften dras innan växlingen.
  factory ExchangeAmounts.fromPaid({
    required double amountFrom,
    required double feePercent,
    required double rate,
  }) {
    final feeAmountFrom = amountFrom * feePercent / 100;
    final amountToGross = amountFrom * rate;
    final amountToNet = (amountFrom - feeAmountFrom) * rate;
    return ExchangeAmounts(
      amountFrom: amountFrom,
      feeAmountFrom: feeAmountFrom,
      amountToGross: amountToGross,
      amountToNet: amountToNet,
      feeAmountTo: amountToGross - amountToNet,
    );
  }

  /// Köp: kunden ska få exakt [buyAmount]. Det kunden betalar räknas
  /// baklänges och avrundas uppåt till hela ören/cent.
  factory ExchangeAmounts.forBuy({
    required double buyAmount,
    required double feePercent,
    required double rate,
  }) {
    final exact = buyAmount / rate / (1 - feePercent / 100);
    final amountFrom = (exact * 100).ceil() / 100;
    final amountToGross = amountFrom * rate;
    return ExchangeAmounts(
      amountFrom: amountFrom,
      feeAmountFrom: amountFrom - buyAmount / rate,
      amountToGross: amountToGross,
      amountToNet: buyAmount,
      feeAmountTo: amountToGross - buyAmount,
    );
  }

  Map<String, dynamic> toMap() => {
    'feeAmountFrom': feeAmountFrom,
    'amountToGross': amountToGross,
    'amountToNet': amountToNet,
    'feeAmountTo': feeAmountTo,
  };
}
