import 'package:flutter/material.dart';

import '../../l10n/locale_controller.dart';
import '../../services/cashier_service.dart';
import '../../theme/app_theme.dart';

/// Kassören skickar pengar till en annan kassör: mottagare, valuta (bara de
/// med saldo), belopp och ett valfritt meddelande.
class CashierSendPage extends StatefulWidget {
  final CashierEntry me;
  final Map<String, double> balances;

  const CashierSendPage({super.key, required this.me, required this.balances});

  @override
  State<CashierSendPage> createState() => _CashierSendPageState();
}

class _CashierSendPageState extends State<CashierSendPage> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _toId;
  String? _currency;
  bool _sending = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _send(List<CashierEntry> recipients) async {
    final l10n = context.l10n;
    final to = recipients.where((r) => r.id == _toId).firstOrNull;
    final currency = _currency;
    final amount = double.tryParse(
      _amountCtrl.text.trim().replaceAll(',', '.'),
    );
    if (to == null || currency == null || amount == null || amount <= 0) {
      _snack(l10n.fillAllFieldsValidAmount);
      return;
    }
    final available = widget.balances[currency] ?? 0;
    if (amount > available + 0.000001) {
      _snack(l10n.notEnoughBalance(available.toStringAsFixed(2), currency));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmTransferTitle),
        content: Text(
          l10n.confirmTransferBody(
            amount.toStringAsFixed(2),
            currency,
            to.label,
          ),
        ),
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

    setState(() => _sending = true);
    try {
      await CashierService.send(
        from: widget.me,
        to: to,
        currency: currency,
        amount: amount,
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      _snack(l10n.transferSent(to.name));
      Navigator.pop(context);
    } on InsufficientBalance {
      _snack(l10n.notEnoughBalance(available.toStringAsFixed(2), currency));
    } catch (e) {
      _snack(l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencies =
        widget.balances.entries
            .where((e) => e.value > 0)
            .map((e) => e.key)
            .toList()
          ..sort();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendMoney)),
      body: StreamBuilder(
        stream: CashierService.directoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.errorWithDetails('${snapshot.error}')),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipients =
              snapshot.data!.where((c) => c.id != widget.me.id).toList()..sort(
                (a, b) =>
                    a.label.toLowerCase().compareTo(b.label.toLowerCase()),
              );

          if (currencies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noBalanceToSend, textAlign: TextAlign.center),
              ),
            );
          }
          if (recipients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noOtherCashiers, textAlign: TextAlign.center),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _toId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.recipientCashier),
                  items: [
                    for (final r in recipients)
                      DropdownMenuItem(value: r.id, child: Text(r.label)),
                  ],
                  onChanged: (v) => setState(() => _toId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: InputDecoration(labelText: l10n.currency),
                  items: [
                    for (final c in currencies)
                      DropdownMenuItem(
                        value: c,
                        child: Text(
                          '$c  (${widget.balances[c]!.toStringAsFixed(2)})',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _currency = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    helperText: _currency == null
                        ? null
                        : l10n.availableBalance(
                            widget.balances[_currency]!.toStringAsFixed(2),
                            _currency!,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteCtrl,
                  maxLength: 500,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l10n.messageOptional),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.transferReservedHint,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text(l10n.send),
                    onPressed: _sending ? null : () => _send(recipients),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
