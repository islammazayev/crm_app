import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../services/exchange_rate_service.dart';
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewExchangePage(
                              side: side,
                              initial: terms,
                              onSubmit: (t, _, note) => PartnerService.counter(
                                ref,
                                side,
                                officeGivesAmount: t.officeGivesAmount,
                                partnerGivesAmount: t.partnerGivesAmount,
                                note: note,
                              ),
                            ),
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

/// Nytt förslag eller motförslag. Man väljer valutorna och skriver beloppet
/// man ger; kursen fylls i med marknadskursen och kan ändras, och beloppet
/// man får räknas ut (som när managern föreslår villkor till en kund).
///
/// [initial] betyder motförslag: valutorna är låsta och belopp och kurs är
/// förifyllda. [partnerChoices] visas för managern vid nytt förslag.
class NewExchangePage extends StatefulWidget {
  final ExchangeSide side;
  final ExchangeTerms? initial;
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
    this.initial,
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
  final _rate = TextEditingController();
  final _note = TextEditingController();
  double? _marketRate;
  bool _loadingRate = false;
  bool _sending = false;

  bool get _isCounter => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      final v = _view(t, widget.side);
      _giveCur = v.giveCur;
      _getCur = v.getCur;
      _give.text = formatRate(v.give);
      _rate.text = formatRate(v.give == 0 ? 0 : v.get / v.give);
      _loadMarketRate(keepTyped: true);
    }
  }

  @override
  void dispose() {
    _give.dispose();
    _rate.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Hämtar marknadskursen när båda valutorna är valda. Går det inte kan
  /// man skriva kursen själv.
  Future<void> _loadMarketRate({bool keepTyped = false}) async {
    final from = _giveCur, to = _getCur;
    setState(() {
      _marketRate = null;
      if (!keepTyped) _rate.clear();
      _loadingRate = from != null && to != null && from != to;
    });
    if (!_loadingRate) return;
    try {
      final rate = await ExchangeRateService.getRate(from!, to!);
      if (!mounted || from != _giveCur || to != _getCur) return;
      setState(() {
        _marketRate = rate;
        if (_rate.text.trim().isEmpty) _rate.text = formatRate(rate);
      });
    } catch (_) {
      // Ingen marknadskurs (t.ex. valutan saknas hos tjänsten).
    } finally {
      if (mounted && from == _giveCur && to == _getCur) {
        setState(() => _loadingRate = false);
      }
    }
  }

  /// Beloppet man får: det man ger gånger kursen, avrundat till ören.
  double? get _getAmount {
    final give = parseRate(_give.text);
    final rate = parseRate(_rate.text);
    if (give == null || rate == null) return null;
    return (give * rate * 100).round() / 100;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final give = parseRate(_give.text);
    final get = _getAmount;
    final needsPartner = widget.side == ExchangeSide.office && !_isCounter;
    if (_giveCur == null ||
        _getCur == null ||
        _giveCur == _getCur ||
        give == null ||
        get == null ||
        get <= 0 ||
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
    final get = _getAmount;

    Widget currency(String? value, String label, ValueChanged<String?> on) =>
        DropdownButtonFormField<String>(
          key: ValueKey('$label-$value'),
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final c in kSupportedCurrencies)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: _isCounter ? null : on,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCounter ? l10n.counterProposal : l10n.newExchange),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.side == ExchangeSide.office && !_isCounter) ...[
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
          currency(_giveCur, l10n.currencyYouGive, (v) {
            _giveCur = v;
            _loadMarketRate();
          }),
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
          currency(_getCur, l10n.currencyYouGet, (v) {
            _getCur = v;
            _loadMarketRate();
          }),
          if (_giveCur != null && _getCur != null && _giveCur != _getCur) ...[
            const SizedBox(height: 16),
            if (_loadingRate && _rate.text.isEmpty)
              Text(l10n.calculating)
            else
              RateField(
                controller: _rate,
                fromCurrency: _giveCur!,
                toCurrency: _getCur!,
                marketRate: _marketRate,
                onChanged: (_) => setState(() {}),
              ),
          ],
          if (get != null && _getCur != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.exchangeYouGet(_money(get, _getCur!)),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
            child: Text(_isCounter ? l10n.send : l10n.sendProposal),
          ),
        ],
      ),
    );
  }
}
