import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/countries.dart';
import 'phone_field.dart';

/// Visar ett land (landskod) med flagga och namn, t.ex. "🇷🇺 Russia".
/// Okända koder visas som de är.
String countryLabel(String iso) {
  for (final c in countries) {
    if (c.iso == iso) return '${c.flag} ${c.name}';
  }
  return iso;
}

/// Admin: länderna där kontoret kan betala ut pengar till mottagaren.
/// Sparas som landskoder (t.ex. ["RU", "TR"]).
class PickupCountriesField extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const PickupCountriesField({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pickupCountries,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.pickupCountriesHelp,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final iso in selected)
              InputChip(
                label: Text(countryLabel(iso)),
                onDeleted: () =>
                    onChanged(selected.where((c) => c != iso).toList()),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(l10n.addCountry),
              onPressed: () async {
                final picked = await pickCountry(context);
                if (picked == null || selected.contains(picked.iso)) return;
                onChanged([...selected, picked.iso]);
              },
            ),
          ],
        ),
      ],
    );
  }
}
