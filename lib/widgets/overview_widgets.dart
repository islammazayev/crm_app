import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_format.dart';
import 'app_shell.dart';

/// "God morgon, Adam" efter tid på dygnet.
String greetingFor(AppLocalizations l10n, String name, [DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour >= 5 && hour < 11) return l10n.greetingMorning(name);
  if (hour >= 11 && hour < 18) return l10n.greetingDay(name);
  return l10n.greetingEvening(name);
}

/// Startsida i appens meny: hälsning och knapp överst, innehållet under.
/// På mobil finns en smal rad med menyknapp och logotyp högst upp.
class OverviewPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  final List<Widget> children;

  const OverviewPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle = '',
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < AppShell.wideBreakpoint;
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (narrow) ...[
              Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.more,
                    icon: const Icon(Icons.menu),
                    onPressed: () => AppShell.of(context).openMenu(),
                  ),
                  const Expanded(child: Center(child: GreenTexLogo(size: 18))),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              header,
              if (action != null) ...[const SizedBox(height: 14), action!],
            ] else
              Row(
                children: [
                  Expanded(child: header),
                  ?action,
                ],
              ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Det gröna saldokortet.
class BalanceHero extends StatelessWidget {
  final String title;
  final Map<String, double> balances;
  final VoidCallback? onTap;

  const BalanceHero({
    super.key,
    required this.title,
    required this.balances,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = balances.entries.where((e) => e.value != 0).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Material(
      color: AppColors.primaryDim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                Text(context.l10n.noBalance)
              else
                Wrap(
                  spacing: 22,
                  runSpacing: 6,
                  children: [
                    for (final e in entries)
                      Text(
                        '${formatMoney(e.value, decimals: e.value.abs() >= 1000 ? 0 : 2)} ${e.key}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// En siffra med rubrik.
class StatData {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const StatData(this.label, this.value, this.color, {this.onTap});
}

/// Siffror på rad, lika breda.
class StatRow extends StatelessWidget {
  final List<StatData> stats;

  const StatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: stats[i].onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats[i].value,
                        style: TextStyle(
                          color: stats[i].color,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Kort med rubrik och rader, t.ex. "Behöver dig nu".
class ListPanel extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<Widget> rows;

  const ListPanel({
    super.key,
    required this.title,
    required this.rows,
    this.emptyText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (rows.isEmpty && emptyText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                emptyText,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          for (final r in rows) ...[
            const Divider(height: 1, color: AppColors.surfaceBorder),
            r,
          ],
        ],
      ),
    );
  }
}

/// En rad i [ListPanel]: text till vänster, färgad etikett till höger.
class StatusRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color color;
  final VoidCallback? onTap;

  const StatusRow({
    super.key,
    required this.title,
    required this.status,
    required this.color,
    this.subtitle = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 140),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Färgen på en transaktions status i listor.
Color statusColor(String status) => switch (status) {
  'customer_requested' || 'customer_countered' => AppColors.warning,
  'payment_confirmed' || 'completed' => AppColors.success,
  'customer_rejected' => AppColors.error,
  _ => AppColors.info,
};
