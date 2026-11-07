import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palettes.dart';

/// Håller appens tema. Valet sparas på enheten, som språket.
class ThemeController extends ValueNotifier<AppPalette> {
  ThemeController._() : super(AppPalette.greentex);

  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'app_theme';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      value = AppPalette.byId(prefs.getString(_prefsKey));
    } catch (_) {
      // Utan sparat val används GreenTex.
    }
  }

  Future<void> setPalette(AppPalette palette) async {
    value = palette;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, palette.id);
    } catch (_) {
      // Valet gäller ändå tills appen stängs.
    }
  }
}
