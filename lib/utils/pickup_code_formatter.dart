import 'package:flutter/services.dart';

/// Sätter in bindestrecken i uthämtningskoden medan managern skriver
/// siffrorna (ÅÅMMDD-XXXX-XXXX). Sifferknappsatsen på iPhone saknar "-".
class PickupCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 14) digits = digits.substring(0, 14);
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 6 || i == 10) out.write('-');
      out.write(digits[i]);
    }
    final text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
