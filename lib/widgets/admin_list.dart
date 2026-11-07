import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';

/// Gemensam design för admin-sidornas listor (kunder, kontor, managers,
/// kassörer, partner): rubrikrad, sök med snabbfilter, rader och sidor.

/// Rubrikrad: kort sammanfattning till vänster, "Lägg till" till höger.
class AdminListHeader extends StatelessWidget {
  final String summary;
  final String addLabel;
  final VoidCallback onAdd;

  const AdminListHeader({
    super.key,
    required this.summary,
    required this.addLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(summary, style: TextStyle(color: AppColors.textMuted)),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(addLabel),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

/// Öppnar ett formulär i en ruta mitt på skärmen. `close` stänger rutan.
Future<void> showFormDialog(
  BuildContext context,
  Widget Function(BuildContext context, VoidCallback close) builder,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: builder(ctx, () {
            if (ctx.mounted) Navigator.pop(ctx);
          }),
        ),
      ),
    ),
  );
}

/// Liten färgad etikett, t.ex. nivå eller status.
class AdminPill extends StatelessWidget {
  final String label;
  final Color color;

  const AdminPill(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

/// Rund bild med initialer (eller en ikon).
class AdminAvatar extends StatelessWidget {
  final String name;
  final IconData? icon;

  const AdminAvatar({super.key, this.name = '', this.icon});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryDim,
      child: icon != null || initials.isEmpty
          ? Icon(
              icon ?? Icons.person_outline,
              size: 18,
              color: AppColors.primary,
            )
          : Text(
              initials,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Ett val i radens ⋮-meny.
class AdminAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const AdminAction(this.label, this.icon, this.onTap, {this.danger = false});
}

/// En rad i listan: tabellrad på bred skärm, kompakt rad på mobil.
class AdminRow extends StatelessWidget {
  final Widget avatar;
  final String title;
  final String subtitle;

  /// Extra kolumner som bara visas på bred skärm.
  final List<String> columns;
  final AdminPill? pill;
  final List<AdminAction> actions;
  final VoidCallback? onTap;

  const AdminRow({
    super.key,
    required this.avatar,
    required this.title,
    this.subtitle = '',
    this.columns = const [],
    this.pill,
    this.actions = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = actions.isEmpty
        ? null
        : PopupMenuButton<int>(
            tooltip: l10n.moreActions,
            icon: Icon(Icons.more_vert, color: AppColors.textMuted),
            onSelected: (i) => actions[i].onTap(),
            itemBuilder: (_) => [
              for (var i = 0; i < actions.length; i++)
                PopupMenuItem(
                  value: i,
                  child: ListTile(
                    leading: Icon(
                      actions[i].icon,
                      color: actions[i].danger ? AppColors.error : null,
                    ),
                    title: Text(
                      actions[i].label,
                      style: actions[i].danger
                          ? TextStyle(color: AppColors.error)
                          : null,
                    ),
                  ),
                ),
            ],
          );
    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
      ],
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minHeight: 56),
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 700;
            return Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(flex: 3, child: name),
                if (wide)
                  for (final (i, c) in columns.indexed)
                    Expanded(
                      flex: 2,
                      child: Text(
                        c,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: i == 0
                            ? null
                            : TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                if (pill != null) ...[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: pill,
                  ),
                ],
                ?menu,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "Visar 1–20 av N" med pilar för föregående och nästa sida.
class AdminPager extends StatelessWidget {
  final int page;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPage;

  const AdminPager({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPage,
  });

  int get pages => total == 0 ? 1 : (total / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = page * pageSize + 1;
    final to = (from + pageSize - 1).clamp(1, total);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.showingRange(from, to, total),
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: l10n.previousPage,
            icon: const Icon(Icons.chevron_left),
            onPressed: page == 0 ? null : () => onPage(page - 1),
          ),
          Text('${page + 1} / $pages'),
          IconButton(
            tooltip: l10n.nextPage,
            icon: const Icon(Icons.chevron_right),
            onPressed: page >= pages - 1 ? null : () => onPage(page + 1),
          ),
        ],
      ),
    );
  }
}

/// Ett snabbfilter ovanför listan.
class AdminFilter<T> {
  final String label;
  final bool Function(T item) test;

  const AdminFilter(this.label, this.test);
}

/// Sökbar lista med snabbfilter och sidor om 20.
///
/// Valt filter (`filter`, index i `filters`, null = alla) ägs av sidan så
/// att statistikrutorna ovanför kan sätta det.
class AdminList<T> extends StatefulWidget {
  final List<T> items;
  final String searchHint;
  final bool Function(T item, String query) matches;
  final List<AdminFilter<T>> filters;
  final int? filter;
  final ValueChanged<int?> onFilter;
  final Widget Function(T item) rowBuilder;
  final String emptyText;
  final int pageSize;

  const AdminList({
    super.key,
    required this.items,
    required this.searchHint,
    required this.matches,
    required this.rowBuilder,
    required this.emptyText,
    this.filters = const [],
    this.filter,
    required this.onFilter,
    this.pageSize = 20,
  });

  @override
  State<AdminList<T>> createState() => _AdminListState<T>();
}

class _AdminListState<T> extends State<AdminList<T>> {
  final _search = TextEditingController();
  String _query = '';
  int _page = 0;

  @override
  void didUpdateWidget(AdminList<T> old) {
    super.didUpdateWidget(old);
    if (old.filter != widget.filter) _page = 0;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = widget.filter;
    final results = widget.items.where((e) {
      if (f != null &&
          f < widget.filters.length &&
          !widget.filters[f].test(e)) {
        return false;
      }
      return _query.trim().isEmpty || widget.matches(e, _query);
    }).toList();
    final pages = results.isEmpty
        ? 1
        : (results.length / widget.pageSize).ceil();
    final page = _page.clamp(0, pages - 1);
    final shown = results
        .skip(page * widget.pageSize)
        .take(widget.pageSize)
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() {
                _query = v;
                _page = 0;
              }),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearSearch,
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _search.clear();
                          _query = '';
                          _page = 0;
                        }),
                      ),
              ),
            ),
          ),
          if (widget.filters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.statAll),
                    selected: f == null,
                    showCheckmark: false,
                    onSelected: (_) => widget.onFilter(null),
                  ),
                  for (final (i, filter) in widget.filters.indexed)
                    ChoiceChip(
                      label: Text(filter.label),
                      selected: f == i,
                      showCheckmark: false,
                      onSelected: (_) => widget.onFilter(f == i ? null : i),
                    ),
                ],
              ),
            ),
          Divider(height: 1, color: AppColors.surfaceBorder),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                widget.emptyText,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          for (final e in shown) widget.rowBuilder(e),
          if (results.isNotEmpty)
            AdminPager(
              page: page,
              pageSize: widget.pageSize,
              total: results.length,
              onPage: (p) => setState(() => _page = p),
            ),
        ],
      ),
    );
  }
}
