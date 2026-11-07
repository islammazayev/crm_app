import 'package:flutter/material.dart';

/// Färgerna i ett tema. Hela appen läser dem via [AppColors].
class AppPalette {
  final String id;
  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surfaceBorder;
  final Color primary;
  final Color primaryDark;
  final Color primaryDim;
  final Color onPrimary;
  final Color textPrimary;
  final Color textMuted;
  final Color textFaint;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color divider;

  const AppPalette({
    required this.id,
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surfaceBorder,
    required this.primary,
    required this.primaryDark,
    required this.primaryDim,
    required this.onPrimary,
    required this.textPrimary,
    required this.textMuted,
    required this.textFaint,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.divider,
  });

  /// GreenTex: mörkt med grönt (som från början).
  static const greentex = AppPalette(
    id: 'greentex',
    brightness: Brightness.dark,
    bg: Color(0xFF0A0F0A),
    surface: Color(0xFF111711),
    surface2: Color(0xFF172017),
    surfaceBorder: Color(0xFF1E2B1E),
    primary: Color(0xFF00E676),
    primaryDark: Color(0xFF00C853),
    primaryDim: Color(0xFF1B3D1E),
    onPrimary: Color(0xFF003300),
    textPrimary: Color(0xFFF0F4F0),
    textMuted: Color(0xFF8A9E8A),
    textFaint: Color(0xFF3D533D),
    success: Color(0xFF00E676),
    error: Color(0xFFFF5252),
    warning: Color(0xFFFFD740),
    info: Color(0xFF40C4FF),
    divider: Color(0xFF1A2A1A),
  );

  /// Ocean: mörkblått.
  static const ocean = AppPalette(
    id: 'ocean',
    brightness: Brightness.dark,
    bg: Color(0xFF0A0F1A),
    surface: Color(0xFF111827),
    surface2: Color(0xFF172033),
    surfaceBorder: Color(0xFF223050),
    primary: Color(0xFF38BDF8),
    primaryDark: Color(0xFF0EA5E9),
    primaryDim: Color(0xFF0C2A3D),
    onPrimary: Color(0xFF04202F),
    textPrimary: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    textFaint: Color(0xFF475569),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF818CF8),
    divider: Color(0xFF1A2235),
  );

  /// Guld: mörkt med guld.
  static const gold = AppPalette(
    id: 'gold',
    brightness: Brightness.dark,
    bg: Color(0xFF0F0D0A),
    surface: Color(0xFF17140F),
    surface2: Color(0xFF201C15),
    surfaceBorder: Color(0xFF332B1E),
    primary: Color(0xFFE7B850),
    primaryDark: Color(0xFFC99A2E),
    primaryDim: Color(0xFF3A2E14),
    onPrimary: Color(0xFF2A1E00),
    textPrimary: Color(0xFFF5F0E6),
    textMuted: Color(0xFFA89F8C),
    textFaint: Color(0xFF5A5142),
    success: Color(0xFF6EE7A0),
    error: Color(0xFFFF6B6B),
    warning: Color(0xFFFFB347),
    info: Color(0xFF7DD3FC),
    divider: Color(0xFF262017),
  );

  /// Violett: mörkt med lila.
  static const violet = AppPalette(
    id: 'violet',
    brightness: Brightness.dark,
    bg: Color(0xFF0E0B16),
    surface: Color(0xFF161222),
    surface2: Color(0xFF1E1830),
    surfaceBorder: Color(0xFF2E2648),
    primary: Color(0xFFA78BFA),
    primaryDark: Color(0xFF8B5CF6),
    primaryDim: Color(0xFF2A1F4A),
    onPrimary: Color(0xFF1E1240),
    textPrimary: Color(0xFFF3F0FA),
    textMuted: Color(0xFFA39DB8),
    textFaint: Color(0xFF54496E),
    success: Color(0xFF4ADE80),
    error: Color(0xFFFB7185),
    warning: Color(0xFFFCD34D),
    info: Color(0xFF67E8F9),
    divider: Color(0xFF211A33),
  );

  /// Ljust: vit bakgrund med grönt.
  static const light = AppPalette(
    id: 'light',
    brightness: Brightness.light,
    bg: Color(0xFFF3F6F4),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F4F1),
    surfaceBorder: Color(0xFFDCE3DE),
    primary: Color(0xFF0E9F5A),
    primaryDark: Color(0xFF0B8049),
    primaryDim: Color(0xFFDDF3E8),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF13201A),
    textMuted: Color(0xFF5B6B62),
    textFaint: Color(0xFF9AA8A0),
    success: Color(0xFF0E9F5A),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFB7791F),
    info: Color(0xFF0277BD),
    divider: Color(0xFFE3E8E5),
  );

  static const all = [greentex, ocean, gold, violet, light];

  static AppPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => greentex);
}
