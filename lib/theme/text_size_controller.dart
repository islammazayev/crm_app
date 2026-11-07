import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Textstorlek i appen, som en faktor på telefonens egen textstorlek.
/// Valet sparas på enheten, som språk och tema.
class TextSizeController extends ValueNotifier<double> {
  TextSizeController._() : super(normal);

  static final TextSizeController instance = TextSizeController._();

  static const _prefsKey = 'app_text_size';

  static const small = 0.9;
  static const normal = 1.0;
  static const large = 1.15;
  static const extraLarge = 1.3;
  static const sizes = [small, normal, large, extraLarge];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_prefsKey);
      if (saved != null && sizes.contains(saved)) value = saved;
    } catch (_) {
      // Utan sparat val används normal storlek.
    }
  }

  Future<void> setSize(double size) async {
    value = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefsKey, size);
    } catch (_) {
      // Valet gäller ändå tills appen stängs.
    }
  }
}
