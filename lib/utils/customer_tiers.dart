import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_localizations.dart';

/// Kundnivåer som admin kan ge kunder. Nivån sparas som [name] i
/// customers/{uid}.tier.
enum CustomerTier { silver, gold, diamond }

extension CustomerTierText on CustomerTier {
  String get emoji => switch (this) {
    CustomerTier.silver => '🥈',
    CustomerTier.gold => '🥇',
    CustomerTier.diamond => '💎',
  };

  String label(AppLocalizations l10n) => switch (this) {
    CustomerTier.silver => l10n.tierSilver,
    CustomerTier.gold => l10n.tierGold,
    CustomerTier.diamond => l10n.tierDiamond,
  };
}

CustomerTier? parseTier(Object? value) {
  for (final t in CustomerTier.values) {
    if (t.name == value) return t;
  }
  return null;
}

/// Visar procent utan onödiga decimaler (1 → "1", 1.5 → "1.5").
String formatPercent(num value) {
  final text = value.toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Rabatt per nivå (procentenheter) från meta/tiers. Standardvärdena är
/// desamma som i firestore.rules och gäller tills admin sparar egna.
class TierSettings {
  static const defaultDiscounts = {
    CustomerTier.silver: 0.5,
    CustomerTier.gold: 1.0,
    CustomerTier.diamond: 1.5,
  };

  final Map<CustomerTier, double> discounts;

  const TierSettings({this.discounts = defaultDiscounts});

  static DocumentReference<Map<String, dynamic>> get ref =>
      FirebaseFirestore.instance.collection('meta').doc('tiers');

  factory TierSettings.fromMap(Map<String, dynamic>? data) {
    final raw = (data?['discounts'] as Map?) ?? const {};
    return TierSettings(
      discounts: {
        for (final t in CustomerTier.values)
          t: (raw[t.name] as num?)?.toDouble() ?? defaultDiscounts[t]!,
      },
    );
  }

  Map<String, dynamic> toMap() => {
    'discounts': {for (final e in discounts.entries) e.key.name: e.value},
  };

  static Stream<TierSettings> watch() =>
      ref.snapshots().map((s) => TierSettings.fromMap(s.data()));

  static Future<TierSettings> load() async =>
      TierSettings.fromMap((await ref.get()).data());

  /// Kundens nivå och rabatt, eller null om kunden saknar nivå.
  /// En egen rabatt på kunden (tierDiscount) går före nivåns.
  CustomerTierInfo? forCustomer(Map<String, dynamic>? customer) {
    final tier = parseTier(customer?['tier']);
    if (tier == null) return null;
    final custom = (customer?['tierDiscount'] as num?)?.toDouble();
    final discount = custom ?? discounts[tier]!;
    return CustomerTierInfo(
      tier: tier,
      discount: discount,
      isCustom: custom != null,
    );
  }
}

class CustomerTierInfo {
  final CustomerTier tier;
  final double discount;
  final bool isCustom;

  const CustomerTierInfo({
    required this.tier,
    required this.discount,
    this.isCustom = false,
  });

  /// Nivån och rabatten som kundens förfrågan bär (se firestore.rules).
  Map<String, dynamic> toTransactionFields() => {
    'customerTier': tier.name,
    'tierDiscount': discount,
  };

  /// Avgiften kunden betalar när managern skriver [baseFee]: rabatten
  /// dras av, men avgiften blir aldrig under 0 (samma som i reglerna).
  double feeAfterDiscount(double baseFee) =>
      baseFee > discount ? baseFee - discount : 0;

  /// Nivån från en transaktion, eller null om den saknar nivå.
  static CustomerTierInfo? fromTransaction(Map<String, dynamic> data) {
    final tier = parseTier(data['customerTier']);
    final discount = (data['tierDiscount'] as num?)?.toDouble();
    if (tier == null || discount == null) return null;
    return CustomerTierInfo(tier: tier, discount: discount);
  }
}
