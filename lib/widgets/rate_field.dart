import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';

/// Visar en växelkurs utan onödiga nollor (0.091200 → "0.0912").
String formatRate(double rate) =>
    rate.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');

/// Läser en kurs som managern har skrivit, eller null om den inte är giltig.
double? parseRate(String text) {
  final v = double.tryParse(text.trim().replaceAll(',', '.'));
  return v != null && v > 0 ? v : null;
}

/// Växelkursen som managern kan ändra. Fältet fylls i med marknadskursen;
/// ändrar managern inget gäller den. Har kursen ändrats visas marknadskursen
/// och en knapp för att gå tillbaka till den.
class RateField extends StatelessWidget {
  final TextEditingController controller;
  final String fromCurrency;
  final String toCurrency;
  final double? marketRate;
  final ValueChanged<double?> onChanged;
  final bool enabled;

  const RateField({
    super.key,
    required this.controller,
    required this.fromCurrency,
    required this.toCurrency,
    required this.marketRate,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rate = parseRate(controller.text);
    final market = marketRate;
    // Jämför som de visas (6 decimaler), annars syns "egen kurs" fast
    // fältet visar marknadskursen.
    final changed =
        market != null &&
        rate != null &&
        formatRate(rate) != formatRate(market);

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) => onChanged(parseRate(text)),
      decoration: InputDecoration(
        labelText: l10n.rateFieldLabel(fromCurrency, toCurrency),
        border: const OutlineInputBorder(),
        errorText: controller.text.trim().isNotEmpty && rate == null
            ? l10n.invalidRate
            : null,
        helperText: changed
            ? l10n.rateChangedFromMarket(formatRate(market))
            : market != null
            ? l10n.marketRateUsed
            : null,
        suffixIcon: changed && enabled
            ? IconButton(
                tooltip: l10n.useMarketRate,
                icon: const Icon(Icons.restart_alt),
                onPressed: () {
                  controller.text = formatRate(market);
                  onChanged(market);
                },
              )
            : null,
      ),
    );
  }
}
