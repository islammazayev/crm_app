import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../services/partner_service.dart';
import '../theme/app_theme.dart';
import '../utils/currencies.dart';
import 'rate_field.dart';

String _money(double v, String c) => '${v.toStringAsFixed(2)} $c';

/// Växlingens status i klartext.
String exchangeStatusText(AppLocalizations l10n, String status) =>
    switch (status) {
      'proposed' => l10n.exchangeProposed,
      'accepted' => l10n.exchangeAccepted,
      'rejected' => l10n.exchangeRejected,
      'cancelled' => l10n.exchangeCancelled,
      'completed' => l10n.exchangeCompleted,
      _ => status,
    };

/// Villkoren sett från [side]: vad den ger och vad den får.
({String giveCur, double give, String getCur, double get}) _view(
  ExchangeTerms t,
  ExchangeSide? side,
) => side == ExchangeSide.partner
    ? (
        giveCur: t.partnerGivesCurrency,
        give: t.partnerGivesAmount,
        getCur: t.officeGivesCurrency,
        get: t.officeGivesAmount,
      )
    : (
        giveCur: t.officeGivesCurrency,
        give: t.officeGivesAmount,
        getCur: t.partnerGivesCurrency,
        get: t.partnerGivesAmount,
      );

/// Lista med växlingar, senaste först. [side] är den inloggades sida och
/// styr vilka knappar som visas; null (admin) visar listan utan knappar.
class PartnerExchangeList extends StatelessWidget {
  final Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> stream;
  final ExchangeSide? side;

  /// Visa bara växlingar som väntar på något (förslag och accepterade).
  final bool onlyOpen;

  const PartnerExchangeList({
    super.key,
    required this.stream,
    required this.side,
    this.onlyOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(l10n.errorWithDetails('${snap.error}'));
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        DateTime at(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            (d.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final docs =
            snap.data!
                .where(
                  (d) =>
                      !onlyOpen ||
                      const ['proposed', 'accepted'].contains(d['status']),
                )
                .toList()
              ..sort((a, b) => at(b).compareTo(at(a)));
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.noExchangesYet,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        return Column(
          children: [for (final d in docs) _ExchangeCard(doc: d, side: side)],
        );
      },
    );
  }
}

class _ExchangeCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final ExchangeSide? side;

  const _ExchangeCard({required this.doc, required this.side});

  @override
  State<_ExchangeCard> createState() => _ExchangeCardState();
}

class _ExchangeCardState extends State<_ExchangeCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorWithDetails('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = widget.doc.data();
    final side = widget.side;
    final terms = ExchangeTerms.fromMap(d);
    final v = _view(terms, side);
    final status = '${d['status'] ?? ''}';
    final mine = side?.name;
    final other = side == ExchangeSide.office ? 'partner' : 'office';
    final myTurn =
        status == 'proposed' && side != null && d['proposedBy'] != mine;
    final counterparty = side == ExchangeSide.partner
        ? '${d['officeLabel'] ?? ''}'
        : '${d['partnerName'] ?? ''}';
    final note = '${d['note'] ?? ''}';
    final ref = widget.doc.reference;

    final lines = <String>[
      if (side == null) ...[
        l10n.exchangeOfficeGives(
          _money(terms.officeGivesAmount, terms.officeGivesCurrency),
        ),
        l10n.exchangePartnerGives(
          _money(terms.partnerGivesAmount, terms.partnerGivesCurrency),
        ),
      ] else ...[
        l10n.exchangeYouGive(_money(v.give, v.giveCur)),
        l10n.exchangeYouGet(_money(v.get, v.getCur)),
      ],
      l10n.exchangeRateLine(
        v.giveCur,
        formatRate(v.give == 0 ? 0 : v.get / v.give),
        v.getCur,
      ),
      if (status == 'accepted' || status == 'completed') ...[
        d['officeSent'] == true
            ? l10n.exchangeOfficeSentDone
            : l10n.exchangeOfficeSentWaiting,
        d['partnerSent'] == true
            ? l10n.exchangePartnerSentDone
            : l10n.exchangePartnerSentWaiting,
      ],
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.currency_exchange, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    side == null
                        ? '${d['partnerName'] ?? ''} ↔ ${d['officeLabel'] ?? ''}'
                        : counterparty,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  exchangeStatusText(l10n, status),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(lines.join('\n'), style: const TextStyle(height: 1.5)),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('"$note"', style: const TextStyle(color: Colors.grey)),
            ],
            if (side != null && !_busy) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (myTurn) ...[
                    ElevatedButton(
                      onPressed: () =>
                          _run(() => PartnerService.decide(ref, 'accepted')),
                      child: Text(l10n.accept),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final t = await showExchangeCounterDialog(
                          context,
                          terms: terms,
                          side: side,
                        );
                        if (t == null) return;
                        await _run(
                          () => PartnerService.counter(
                            ref,
                            side,
                            officeGivesAmount: t.officeGivesAmount,
                            partnerGivesAmount: t.partnerGivesAmount,
                          ),
                        );
                      },
                      child: Text(l10n.counterProposal),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () =>
                          _run(() => PartnerService.decide(ref, 'rejected')),
                      child: Text(l10n.reject),
                    ),
                  ],
                  if (status == 'proposed' && !myTurn) ...[
                    Text(
                      l10n.waitingForAnswer,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () =>
                          _run(() => PartnerService.decide(ref, 'cancelled')),
                      child: Text(l10n.cancel),
                    ),
                  ],
                  if (status == 'accepted' && d['${mine}Sent'] != true)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.outbox_outlined),
                      label: Text(
                        l10n.markExchangeSent(_money(v.give, v.giveCur)),
                      ),
                      onPressed: () async {
                        if (await _confirm(
                          l10n.markExchangeSent(_money(v.give, v.giveCur)),
                          l10n.confirmExchangeSent,
                        )) {
                          await _run(() => PartnerService.markSent(ref, side));
                        }
                      },
                    ),
                  if (status == 'accepted' &&
                      d['${other}Sent'] == true &&
                      d['${mine}Received'] != true)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      icon: const Icon(Icons.move_to_inbox_outlined),
                      label: Text(
                        l10n.markExchangeReceived(_money(v.get, v.getCur)),
                      ),
                      onPressed: () async {
                        if (await _confirm(
                          l10n.markExchangeReceived(_money(v.get, v.getCur)),
                          l10n.confirmExchangeReceived,
                        )) {
                          await _run(
                            () => PartnerService.markReceived(widget.doc, side),
                          );
                        }
                      },
                    ),
                  if (status == 'accepted' &&
                      d['${mine}Received'] == true &&
                      d['${other}Received'] != true)
                    Text(
                      l10n.waitingForOtherReceived,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Motförslag: samma valutor, nya belopp.
Future<ExchangeTerms?> showExchangeCounterDialog(
  BuildContext context, {
  required ExchangeTerms terms,
  required ExchangeSide side,
}) {
  final v = _view(terms, side);
  final giveCtrl = TextEditingController(text: v.give.toString());
  final getCtrl = TextEditingController(text: v.get.toString());
  final l10n = context.l10n;
  return showDialog<ExchangeTerms>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.counterProposal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: giveCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.youGiveLabel,
              suffixText: v.giveCur,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: getCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.youGetLabel,
              suffixText: v.getCur,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final give = parseRate(giveCtrl.text);
            final get = parseRate(getCtrl.text);
            if (give == null || get == null) return;
            Navigator.pop(
              ctx,
              side == ExchangeSide.office
                  ? ExchangeTerms(
                      officeGivesCurrency: v.giveCur,
                      officeGivesAmount: give,
                      partnerGivesCurrency: v.getCur,
                      partnerGivesAmount: get,
                    )
                  : ExchangeTerms(
                      officeGivesCurrency: v.getCur,
                      officeGivesAmount: get,
                      partnerGivesCurrency: v.giveCur,
                      partnerGivesAmount: give,
                    ),
            );
          },
          child: Text(l10n.send),
        ),
      ],
    ),
  );
}

/// Nytt förslag: valuta och belopp man ger och får. Kursen visas medan man
/// skriver. [partnerChoices] visas för managern (vilken partner).
class NewExchangePage extends StatefulWidget {
  final ExchangeSide side;
  final Map<String, String> partnerChoices;
  final Future<void> Function(
    ExchangeTerms terms,
    String? partnerId,
    String note,
  )
  onSubmit;

  const NewExchangePage({
    super.key,
    required this.side,
    required this.onSubmit,
    this.partnerChoices = const {},
  });

  @override
  State<NewExchangePage> createState() => _NewExchangePageState();
}

class _NewExchangePageState extends State<NewExchangePage> {
  String? _partnerId;
  String? _giveCur;
  String? _getCur;
  final _give = TextEditingController();
  final _get = TextEditingController();
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _give.dispose();
    _get.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final give = parseRate(_give.text);
    final get = parseRate(_get.text);
    final needsPartner = widget.side == ExchangeSide.office;
    if (_giveCur == null ||
        _getCur == null ||
        _giveCur == _getCur ||
        give == null ||
        get == null ||
        (needsPartner && _partnerId == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFieldsValidAmount)));
      return;
    }
    final terms = widget.side == ExchangeSide.office
        ? ExchangeTerms(
            officeGivesCurrency: _giveCur!,
            officeGivesAmount: give,
            partnerGivesCurrency: _getCur!,
            partnerGivesAmount: get,
          )
        : ExchangeTerms(
            officeGivesCurrency: _getCur!,
            officeGivesAmount: get,
            partnerGivesCurrency: _giveCur!,
            partnerGivesAmount: give,
          );
    setState(() => _sending = true);
    try {
      await widget.onSubmit(terms, _partnerId, _note.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exchangeProposalSent)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final give = parseRate(_give.text);
    final get = parseRate(_get.text);

    Widget currency(String? value, String label, ValueChanged<String?> on) =>
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final c in kSupportedCurrencies)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: on,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newExchange)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.side == ExchangeSide.office) ...[
            DropdownButtonFormField<String>(
              initialValue: _partnerId,
              decoration: InputDecoration(labelText: l10n.choosePartner),
              items: [
                for (final e in widget.partnerChoices.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _partnerId = v),
            ),
            const SizedBox(height: 16),
          ],
          currency(
            _giveCur,
            l10n.currencyYouGive,
            (v) => setState(() => _giveCur = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _give,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.youGiveLabel,
              suffixText: _giveCur,
            ),
          ),
          const SizedBox(height: 20),
          currency(
            _getCur,
            l10n.currencyYouGet,
            (v) => setState(() => _getCur = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _get,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.youGetLabel,
              suffixText: _getCur,
            ),
          ),
          if (give != null &&
              get != null &&
              _giveCur != null &&
              _getCur != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.exchangeRateLine(
                _giveCur!,
                formatRate(get / give),
                _getCur!,
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLength: 500,
            decoration: InputDecoration(labelText: l10n.messageOptional),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sending ? null : _submit,
            child: Text(l10n.sendProposal),
          ),
        ],
      ),
    );
  }
}
