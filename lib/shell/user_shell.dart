import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/widgets/brand_logo.dart';
import 'package:reaple_app/features/cart/presentation/cart_count_controller.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// HP: Bottom Navigation Bar. Layar lebar: Navigation Rail.
class UserShell extends ConsumerWidget {
  const UserShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    _NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Keranjang', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
    _NavItem('Riwayat', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _NavItem('Chat', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
    _NavItem('Profil', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final index = navigationShell.currentIndex;

    void select(int i) => navigationShell.goBranch(i, initialLocation: i == index);

    Widget icon(int i, {bool selected = false}) {
      final base = Icon(selected ? _items[i].selectedIcon : _items[i].icon);
      if (i != 1) return base;

      return Badge(
        isLabelVisible: cartCount > 0,
        label: Text(cartCount > 99 ? '99+' : '$cartCount'),
        child: base,
      );
    }

    if (!context.isCompact) {
      final extended = context.isExpanded;

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: extended,
                selectedIndex: index,
                onDestinationSelected: select,
                labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: BrandLogo(size: 40, showName: extended),
                ),
                destinations: [
                  for (var i = 0; i < _items.length; i++)
                    NavigationRailDestination(
                      icon: icon(i),
                      selectedIcon: icon(i, selected: true),
                      label: Text(_items[i].label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: select,
        destinations: [
          for (var i = 0; i < _items.length; i++)
            NavigationDestination(
              icon: icon(i),
              selectedIcon: icon(i, selected: true),
              label: _items[i].label,
            ),
        ],
      ),
    );
  }
}