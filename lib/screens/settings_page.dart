import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_palettes.dart';
import '../theme/app_theme.dart';
import '../theme/text_size_controller.dart';
import '../theme/theme_controller.dart';
import 'auth_gate.dart';

/// Inställningar för alla roller: konto, språk, lösenord och om appen.
/// Nya inställningar läggs till som rader i en sektion (se [_Section]).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const appVersion = '0.1.0';

  String _roleLabel(AppLocalizations l10n, Map<String, dynamic>? d) {
    final role = switch (d?['role']) {
      'admin' => l10n.roleAdmin,
      'manager' => l10n.roleManager,
      'cashier' => l10n.roleCashier,
      'partner' => l10n.rolePartner,
      _ => l10n.roleCustomer,
    };
    return d?['alsoCashier'] == true ? '$role + ${l10n.roleCashier}' : role;
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final l10n = context.l10n;
    final current = LocaleController.instance.value?.languageCode ?? '';
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          for (final e in {
            '': l10n.languageSystem,
            ...LocaleController.languages,
          }.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: e.key == current
                        ? const Icon(Icons.check, size: 18)
                        : null,
                  ),
                  Text(e.value),
                ],
              ),
            ),
        ],
      ),
    );
    if (code == null) return;
    await LocaleController.instance.setLocale(
      code.isEmpty ? null : Locale(code),
    );
  }

  /// Väljer tema. Hela appen ritas om och man hamnar på startsidan.
  Future<void> _chooseTheme(BuildContext context) async {
    final l10n = context.l10n;
    final current = ThemeController.instance.value;
    final chosen = await showDialog<AppPalette>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsTheme),
        children: [
          for (final p in AppPalette.all)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, p),
              child: Row(
                children: [
                  _Swatch(palette: p),
                  const SizedBox(width: 14),
                  Expanded(child: Text(themeName(l10n, p))),
                  if (p.id == current.id)
                    Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen == null || chosen.id == current.id) return;
    await ThemeController.instance.setPalette(chosen);
  }

  /// Väljer textstorlek. Varje val visas i sin egen storlek.
  Future<void> _chooseTextSize(BuildContext context) async {
    final l10n = context.l10n;
    final current = TextSizeController.instance.value;
    final chosen = await showDialog<double>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsTextSize),
        children: [
          for (final size in TextSizeController.sizes)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, size),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      textSizeName(l10n, size),
                      textScaler: TextScaler.linear(
                        MediaQuery.textScalerOf(ctx).scale(14) /
                            14 /
                            current *
                            size,
                      ),
                    ),
                  ),
                  if (size == current)
                    Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null) await TextSizeController.instance.setSize(chosen);
  }

  /// Skickar en länk till den egna e-posten där man väljer nytt lösenord.
  Future<void> _changePassword(BuildContext context) async {
    final l10n = context.l10n;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsChangePassword),
        content: Text(l10n.settingsChangePasswordConfirm(email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.send),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsChangePasswordSent(email))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = FirebaseAuth.instance.currentUser;
    final languageCode = LocaleController.instance.value?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? '')
            .snapshots(),
        builder: (context, snap) {
          final d = snap.data?.data();
          final name = '${d?['firstName'] ?? ''} ${d?['lastName'] ?? ''}'
              .trim();
          final phone = '${d?['phone'] ?? ''}';
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _Section(
                    title: l10n.settingsAccount,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryDim,
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(name.isEmpty ? (user?.email ?? '') : name),
                        subtitle: Text(_roleLabel(l10n, d)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.mail_outline),
                        title: Text(l10n.email),
                        subtitle: Text(user?.email ?? ''),
                      ),
                      if (phone.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: Text(l10n.phone),
                          subtitle: Text(phone),
                        ),
                    ],
                  ),
                  _Section(
                    title: l10n.settingsGeneral,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.settingsLanguage),
                        subtitle: Text(
                          languageCode == null
                              ? l10n.languageSystem
                              : LocaleController.languages[languageCode] ?? '',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _chooseLanguage(context),
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.settingsAppearance,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: Text(l10n.settingsTheme),
                        subtitle: Text(
                          themeName(l10n, ThemeController.instance.value),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _chooseTheme(context),
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: TextSizeController.instance,
                        builder: (context, size, _) => ListTile(
                          leading: const Icon(Icons.format_size),
                          title: Text(l10n.settingsTextSize),
                          subtitle: Text(textSizeName(l10n, size)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _chooseTextSize(context),
                        ),
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.settingsSecurity,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text(l10n.settingsChangePassword),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _changePassword(context),
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.settingsAbout,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('GreenTex'),
                        subtitle: Text(l10n.settingsVersion(appVersion)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.logout),
                    onPressed: () => signOutToLogin(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// En rubrik och ett kort med rader.
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

/// Temats namn i valt språk.
String themeName(AppLocalizations l10n, AppPalette p) => switch (p.id) {
  'ocean' => l10n.themeOcean,
  'gold' => l10n.themeGold,
  'violet' => l10n.themeViolet,
  'light' => l10n.themeLight,
  _ => l10n.themeGreentex,
};

/// Liten förhandsvisning av ett tema: bakgrund, yta och accentfärg.
class _Swatch extends StatelessWidget {
  final AppPalette palette;

  const _Swatch({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 12,
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Textstorlekens namn i valt språk.
String textSizeName(AppLocalizations l10n, double size) => switch (size) {
  TextSizeController.small => l10n.textSizeSmall,
  TextSizeController.large => l10n.textSizeLarge,
  TextSizeController.extraLarge => l10n.textSizeExtraLarge,
  _ => l10n.textSizeNormal,
};
