import 'package:flutter/material.dart';

import 'app_palettes.dart';
import 'theme_controller.dart';

// ══════════════════════════════════════════════════════════════════
//  GreenTex Design System
//  Färgerna kommer från det valda temat (app_palettes.dart).
// ══════════════════════════════════════════════════════════════════

/// Appens färger i det valda temat (se [AppPalette] och
/// [ThemeController]).
class AppColors {
  static AppPalette get _p => ThemeController.instance.value;

  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get surface2 => _p.surface2;
  static Color get surfaceBorder => _p.surfaceBorder;
  static Color get primary => _p.primary;
  static Color get primaryDark => _p.primaryDark;
  static Color get primaryDim => _p.primaryDim;
  static Color get onPrimary => _p.onPrimary;
  static Color get textPrimary => _p.textPrimary;
  static Color get textMuted => _p.textMuted;
  static Color get textFaint => _p.textFaint;
  static Color get success => _p.success;
  static Color get error => _p.error;
  static Color get warning => _p.warning;
  static Color get info => _p.info;
  static Color get divider => _p.divider;
}

class AppTheme {
  /// Temat för den valda paletten.
  static ThemeData get current {
    final dark = ThemeController.instance.value.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,

      // ── Färger ───────────────────────────────────────────────────
      colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.primaryDark,
            onSecondary: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            error: AppColors.error,
            onError: Colors.white,
            outline: AppColors.surfaceBorder,
          ),

      scaffoldBackgroundColor: AppColors.bg,

      // ── AppBar ───────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        actionsIconTheme: IconThemeData(color: AppColors.primary),
        shape: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // ── InputDecoration ──────────────────────────────────────────
      // Luftiga fält med tydlig ram; etiketten blir grön när fältet har fokus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.surfaceBorder.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 14),
        helperStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),

      // Rullgardinsmenyer (DropdownButtonFormField) får samma färg som fälten.
      canvasColor: AppColors.surface2,

      // ── ElevatedButton ───────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // ── DropdownMenu ─────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface2,
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── IconButton ───────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          highlightColor: AppColors.primaryDim,
        ),
      ),

      // ── ListTile ─────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: AppColors.primary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),

      // ── Dialog ───────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        elevation: 24,
      ),

      // ── SnackBar ─────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        actionTextColor: AppColors.primary,
      ),

      // ── TabBar ───────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),

      // ── Chip ─────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryDim,
        labelStyle: TextStyle(color: AppColors.primary, fontSize: 12),
        side: BorderSide(color: AppColors.primary, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── PopupMenu ────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
        textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),

      // ── Scrollbar ────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.primaryDim),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(4),
      ),

      // ── Text ─────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textMuted, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textFaint, fontSize: 12),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  Hjälp-widgets som används genomgående i hela appen
// ──────────────────────────────────────────────────────────────────

/// Sektion-header med grön vänsterlinje
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Glassmorphism-inspirerat kort
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const GlassCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: child,
    );
  }
}

/// Grön status-badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  const StatusBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
