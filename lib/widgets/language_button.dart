import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';

/// Knapp i appbaren som byter språk. Det valda språket har en bock.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  static const _system = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = LocaleController.instance.value?.languageCode ?? _system;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.languageTooltip,
      onSelected: (code) => LocaleController.instance.setLocale(
        code == _system ? null : Locale(code),
      ),
      itemBuilder: (context) => [
        _item(_system, l10n.languageSystem, current),
        const PopupMenuDivider(),
        for (final e in LocaleController.languages.entries)
          _item(e.key, e.value, current),
      ],
    );
  }

  PopupMenuItem<String> _item(String code, String label, String current) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: code == current ? const Icon(Icons.check, size: 18) : null,
          ),
          Text(label),
        ],
      ),
    );
  }
}
