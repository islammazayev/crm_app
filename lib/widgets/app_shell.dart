import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
import '../screens/auth_gate.dart';
import '../theme/app_theme.dart';

/// Ett val i appens meny.
class ShellDestination {
  final IconData icon;
  final String label;
  final int badge;
  final WidgetBuilder builder;

  const ShellDestination({
    required this.icon,
    required this.label,
    required this.builder,
    this.badge = 0,
  });
}

/// En knapp i menyn som gör något i stället för att visa en sida.
class ShellAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ShellAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Appens ram: sidomeny på bred skärm, bottenmeny med ikoner på mobil. På
/// mobil visas de [mobileCount] första valen, [primaryAction] som en grön
/// knapp i mitten, och resten finns under menyknappen.
///
/// Varje val har en egen navigator, så menyn finns kvar när man öppnar en
/// undersida och varje val minns var man var.
class AppShell extends StatefulWidget {
  final List<ShellDestination> destinations;
  final int mobileCount;
  final ShellAction? primaryAction;

  /// Visas längst ner i sidomenyn och i menyn på mobil, t.ex. byt roll.
  final List<ShellAction> extraActions;

  const AppShell({
    super.key,
    required this.destinations,
    this.mobileCount = 4,
    this.primaryAction,
    this.extraActions = const [],
  });

  static const wideBreakpoint = 840.0;

  /// Ramen runt [context], för att byta val eller öppna menyn.
  static AppShellState of(BuildContext context) =>
      context.findAncestorStateOfType<AppShellState>()!;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _opened = {0};
  final List<GlobalKey<NavigatorState>> _navigators = [];

  GlobalKey<NavigatorState> _navigator(int i) {
    while (_navigators.length <= i) {
      _navigators.add(GlobalKey<NavigatorState>());
    }
    return _navigators[i];
  }

  /// Byter val. Trycker man på valet man redan är på går man till dess början.
  void select(int index) {
    if (index == _index) {
      _navigator(index).currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  /// Öppnar en sida inne i valet man är på, så att menyn finns kvar.
  void push(Widget page) {
    _navigator(
      _index,
    ).currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  /// Menyn på mobil: valen som inte får plats, extra knappar och logga ut.
  Future<void> openMenu() async {
    final d = widget.destinations;
    final l10n = context.l10n;
    final chosen = await showModalBottomSheet<VoidCallback>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = widget.mobileCount; i < d.length; i++)
                ListTile(
                  leading: _BadgeIcon(icon: d[i].icon, badge: d[i].badge),
                  title: Text(d[i].label),
                  selected: i == _index,
                  onTap: () => Navigator.pop(ctx, () => select(i)),
                ),
              for (final a in widget.extraActions)
                ListTile(
                  leading: Icon(a.icon),
                  title: Text(a.label),
                  onTap: () => Navigator.pop(ctx, a.onTap),
                ),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text(l10n.logout),
                onTap: () => Navigator.pop(ctx, () => signOutToLogin(context)),
              ),
            ],
          ),
        ),
      ),
    );
    chosen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.destinations;
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < d.length; i++)
          // Sidor öppnas först när man går till dem.
          _opened.contains(i)
              ? Navigator(
                  key: _navigator(i),
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    settings: settings,
                    builder: d[i].builder,
                  ),
                )
              : const SizedBox.shrink(),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= AppShell.wideBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                _SideMenu(
                  destinations: d,
                  extraActions: widget.extraActions,
                  index: _index,
                  onSelect: select,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: _BottomMenu(
            destinations: d.take(widget.mobileCount).toList(),
            moreBadge: d
                .skip(widget.mobileCount)
                .fold<int>(0, (sum, e) => sum + e.badge),
            index: _index,
            primaryAction: widget.primaryAction,
            onSelect: select,
            onMore: openMenu,
          ),
        );
      },
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int badge;
  final Color? color;

  const _BadgeIcon({required this.icon, required this.badge, this.color});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: badge > 0,
      label: Text('$badge'),
      child: Icon(icon, color: color),
    );
  }
}

/// Bottenmeny med bara ikoner och en grön knapp i mitten. Namnen finns som
/// tooltip och för skärmläsare.
class _BottomMenu extends StatelessWidget {
  final List<ShellDestination> destinations;
  final int moreBadge;
  final int index;
  final ShellAction? primaryAction;
  final ValueChanged<int> onSelect;
  final VoidCallback onMore;

  const _BottomMenu({
    required this.destinations,
    required this.moreBadge,
    required this.index,
    required this.primaryAction,
    required this.onSelect,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < destinations.length; i++)
        IconButton(
          tooltip: destinations[i].label,
          onPressed: () => onSelect(i),
          icon: _BadgeIcon(
            icon: destinations[i].icon,
            badge: destinations[i].badge,
            color: i == index ? AppColors.primary : AppColors.textMuted,
          ),
        ),
    ];
    final action = primaryAction;
    if (action != null) {
      items.insert(
        (items.length / 2).ceil(),
        Tooltip(
          message: action.label,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: action.onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(action.icon, color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      );
    }
    items.add(
      IconButton(
        tooltip: context.l10n.more,
        onPressed: onMore,
        icon: _BadgeIcon(
          icon: Icons.menu,
          badge: moreBadge,
          color: index >= destinations.length
              ? AppColors.primary
              : AppColors.textMuted,
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items,
          ),
        ),
      ),
    );
  }
}

/// Appens namn, som i logotypen.
class GreenTexLogo extends StatelessWidget {
  final double size;

  const GreenTexLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Green',
        children: [
          TextSpan(
            text: 'Tex',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final List<ShellDestination> destinations;
  final List<ShellAction> extraActions;
  final int index;
  final ValueChanged<int> onSelect;

  const _SideMenu({
    required this.destinations,
    required this.extraActions,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 8, 10, 20),
                    child: GreenTexLogo(),
                  ),
                  for (var i = 0; i < destinations.length; i++)
                    _SideItem(
                      icon: destinations[i].icon,
                      label: destinations[i].label,
                      badge: destinations[i].badge,
                      selected: i == index,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceBorder),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final a in extraActions)
                    _SideItem(icon: a.icon, label: a.label, onTap: a.onTap),
                  _SideItem(
                    icon: Icons.logout,
                    label: context.l10n.logout,
                    onTap: () => signOutToLogin(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  const _SideItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.primaryDim : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badge > 0)
                  Text(
                    '$badge',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
