import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_tiers.dart';

/// Admin: rabatt (procentenheter) per kundnivå.
class AdminTiersPage extends StatefulWidget {
  const AdminTiersPage({super.key});

  @override
  State<AdminTiersPage> createState() => _AdminTiersPageState();
}

class _AdminTiersPageState extends State<AdminTiersPage> {
  final _discountCtrls = {
    for (final t in CustomerTier.values) t: TextEditingController(),
  };
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    TierSettings settings;
    try {
      settings = await TierSettings.load();
    } catch (_) {
      settings = const TierSettings();
    }
    if (!mounted) return;
    setState(() {
      for (final t in CustomerTier.values) {
        _discountCtrls[t]!.text = formatPercent(settings.discounts[t]!);
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in _discountCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final l10n = context.l10n;
    final discounts = {
      for (final t in CustomerTier.values) t: _parse(_discountCtrls[t]!),
    };
    if (discounts.values.any((d) => d == null || d < 0 || d > 100)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tierInvalidValues)));
      return;
    }

    setState(() => _saving = true);
    try {
      await TierSettings.ref.set(
        TierSettings(
          discounts: discounts.map((t, d) => MapEntry(t, d!)),
        ).toMap(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tierSettingsSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget field(TextEditingController c, String label, {String? helper}) =>
        TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            suffixText: '%',
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerTiers)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerTiersIntro,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final t in CustomerTier.values) ...[
                    field(
                      _discountCtrls[t]!,
                      l10n.tierDiscountLabel('${t.emoji} ${t.label(l10n)}'),
                      helper: () {
                        final d = _parse(_discountCtrls[t]!);
                        if (d == null) return null;
                        // Exempel med 5 % så att admin ser vad rabatten gör.
                        return l10n.tierFeeExample(
                          formatPercent(
                            CustomerTierInfo(
                              tier: t,
                              discount: d,
                            ).feeAfterDiscount(5),
                          ),
                        );
                      }(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
