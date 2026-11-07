import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/customer_tiers.dart';
import '../../widgets/admin_list.dart';
import '../../widgets/form_width.dart';
import '../../widgets/overview_widgets.dart';
import 'admin_customers_page.dart';

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

  /// Alla kunder, för att räkna hur många som har varje nivå.
  late final _customers = FirebaseFirestore.instance
      .collection('customers')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerTiers)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _customers,
              builder: (context, snap) {
                final counts = <String?, int>{};
                for (final d in snap.data?.docs ?? const []) {
                  final tier = parseTier(d.data()['tier'])?.name;
                  counts[tier] = (counts[tier] ?? 0) + 1;
                }
                String count(String? tier) =>
                    snap.hasData ? '${counts[tier] ?? 0}' : '…';
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FormWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.customerTiersIntro,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StatRow(
                          stats: [
                            StatData(
                              l10n.tierNone,
                              count(null),
                              AppColors.textMuted,
                              onTap: () => _openCustomers('none'),
                            ),
                            for (final t in CustomerTier.values)
                              StatData(
                                '${t.emoji} ${t.label(l10n)}',
                                count(t.name),
                                AppColors.warning,
                                onTap: () => _openCustomers(t.name),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        for (final t in CustomerTier.values) ...[
                          _tierCard(t, count(t.name)),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: Text(l10n.save),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _openCustomers(String tier) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AdminCustomersPage(initialTier: tier)),
  );

  /// Ett kort per nivå: rabatt, exempel och "Visa kunder".
  Widget _tierCard(CustomerTier t, String count) {
    final l10n = context.l10n;
    final d = _parse(_discountCtrls[t]!);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.emoji} ${t.label(l10n)}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AdminPill(l10n.tierCustomerCount(count), AppColors.warning),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _discountCtrls[t],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.tierDiscountLabel(
                  '${t.emoji} ${t.label(l10n)}',
                ),
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                if (d != null)
                  // Exempel med 5 % så att admin ser vad rabatten gör.
                  Text(
                    l10n.tierFeeExample(
                      formatPercent(
                        CustomerTierInfo(
                          tier: t,
                          discount: d,
                        ).feeAfterDiscount(5),
                      ),
                    ),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.chevron_right),
                  iconAlignment: IconAlignment.end,
                  label: Text(l10n.showCustomers),
                  onPressed: () => _openCustomers(t.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
