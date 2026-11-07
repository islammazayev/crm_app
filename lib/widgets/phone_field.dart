import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/countries.dart';

/// Telefonfält med landskod. Man väljer land (förvalt Sverige) och skriver
/// numret; [controller] får hela numret, t.ex. "+46701234567".
///
/// Äldre nummer utan landskod visas som de är och ändras inte förrän man
/// skriver i fältet eller byter land.
class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const PhoneField({
    super.key,
    required this.controller,
    required this.decoration,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final _national = TextEditingController();
  Country _country = countryByIso(defaultCountryIso);

  /// Senaste värdet vi själva skrev till controllern.
  String? _written;

  @override
  void initState() {
    super.initState();
    _load(widget.controller.text);
    widget.controller.addListener(_onExternal);
  }

  @override
  void didUpdateWidget(PhoneField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onExternal);
      widget.controller.addListener(_onExternal);
      _load(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternal);
    _national.dispose();
    super.dispose();
  }

  /// Läser in ett helt nummer (t.ex. när formuläret fylls i eller töms).
  void _load(String value) {
    final parsed = parsePhone(value, preferIso: _country.iso);
    if (parsed != null) {
      _country = parsed.country;
      _national.text = parsed.national;
    } else {
      _national.text = value;
    }
    _written = value;
  }

  void _onExternal() {
    if (widget.controller.text == _written) return;
    setState(() => _load(widget.controller.text));
  }

  void _write() {
    final value = composePhone(_country, _national.text);
    _written = value;
    widget.controller.text = value;
    widget.onChanged?.call(value);
  }

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CountryPicker(),
    );
    if (picked == null) return;
    setState(() => _country = picked);
    if (_national.text.trim().isNotEmpty) _write();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: _national,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      onChanged: (_) => _write(),
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(widget.controller.text),
      decoration: widget.decoration.copyWith(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: TextButton(
            onPressed: widget.enabled ? _pickCountry : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 40),
            ),
            child: Text(
              '${_country.flag} +${_country.dial} ▾',
              semanticsLabel: l10n.chooseCountryCode,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lista med länder och sök. De vanligaste länderna ligger överst.
class _CountryPicker extends StatefulWidget {
  const _CountryPicker();

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase().replaceFirst('+', '');
    bool hit(Country c) =>
        q.isEmpty ||
        c.name.toLowerCase().contains(q) ||
        c.iso.toLowerCase() == q ||
        c.dial.startsWith(q);
    final top = [
      for (final iso in topCountryIsos) countryByIso(iso),
    ].where(hit).toList();
    final rest = countries.where(hit).toList();

    Widget tile(Country c) => ListTile(
      leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
      title: Text(c.name),
      trailing: Text(
        '+${c.dial}',
        style: TextStyle(color: AppColors.textMuted),
      ),
      onTap: () => Navigator.pop(context, c),
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchCountry,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...top.map(tile),
                if (top.isNotEmpty && rest.isNotEmpty) const Divider(),
                ...rest.map(tile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
