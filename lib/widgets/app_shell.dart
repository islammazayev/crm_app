import 'package:flutter/material.dart';

import '../l10n/locale_controller.dart';
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

/// Appens ram: sidomeny på bred skärm, bottenmeny på mobil. På mobil visas
/// de [mobileCount] första valen, och resten finns under "Mer".
///
/// Varje val har en egen navigator, så menyn finns kvar när man öppnar en
/// undersida och varje val minns var man var.
class AppShell extends StatefulWidget {
  final List<ShellDestination> destinations;
  final int mobileCount;

  const AppShell({super.key, required this.destinations, this.mobileCount = 4});

  static const wideBreakpoint = 840.0;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _opened = {0};
  late final List<GlobalKey<NavigatorState>> _navigators = [
    for (final _ in widget.destinations) GlobalKey<NavigatorState>(),
  ];

  /// Byter val. Trycker man på valet man redan är på går man till dess början.
  void select(int index) {
    if (index == _index) {
      _navigators[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  Future<void> _showMore(BuildContext context) async {
    final d = widget.destinations;
    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = widget.mobileCount; i < d.length; i++)
              ListTile(
                leading: _BadgeIcon(icon: d[i].icon, badge: d[i].badge),
                title: Text(d[i].label),
                selected: i == _index,
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) select(chosen);
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
                  key: _navigators[i],
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
                _SideMenu(destinations: d, index: _index, onSelect: select),
                Expanded(child: body),
              ],
            ),
          );
        }
        final moreBadge = d
            .skip(widget.mobileCount)
            .fold<int>(0, (sum, e) => sum + e.badge);
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryDim,
            height: 64,
            selectedIndex: _index < widget.mobileCount
                ? _index
                : widget.mobileCount,
            onDestinationSelected: (i) =>
                i < widget.mobileCount ? select(i) : _showMore(context),
            destinations: [
              for (final e in d.take(widget.mobileCount))
                NavigationDestination(
                  icon: _BadgeIcon(icon: e.icon, badge: e.badge),
                  label: e.label,
                ),
              NavigationDestination(
                icon: _BadgeIcon(icon: Icons.menu, badge: moreBadge),
                label: context.l10n.more,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int badge;

  const _BadgeIcon({required this.icon, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: badge > 0,
      label: Text('$badge'),
      child: Icon(icon),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final List<ShellDestination> destinations;
  final int index;
  final ValueChanged<int> onSelect;

  const _SideMenu({
    required this.destinations,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
              child: Text.rich(
                const TextSpan(
                  text: 'Green',
                  children: [
                    TextSpan(
                      text: 'Tex',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (var i = 0; i < destinations.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: i == index ? AppColors.primaryDim : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            destinations[i].icon,
                            size: 20,
                            color: i == index
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              destinations[i].label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: i == index
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: i == index
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (destinations[i].badge > 0)
                            Badge(label: Text('${destinations[i].badge}')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
