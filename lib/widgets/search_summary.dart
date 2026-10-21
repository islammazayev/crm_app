import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';

/// Raden under en sökruta: uppmaning att skriva, antal träffar, att listan är
/// begränsad, eller att inget hittades.
class SearchSummary extends StatelessWidget {
  final bool empty;
  final int total;
  final int matches;
  final int shown;

  const SearchSummary({
    super.key,
    required this.empty,
    required this.total,
    required this.matches,
    required this.shown,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String text;
    if (empty) {
      text = l10n.typeToSearch(total);
    } else if (matches == 0) {
      text = l10n.noSearchMatches;
    } else if (shown < matches) {
      text = l10n.customersShownLimited(shown, matches);
    } else {
      text = l10n.searchMatches(matches);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}
