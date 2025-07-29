import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < AppConfig.mobileBreakpoint) {
      // Mobile layout with Drawer
      return Scaffold(
        appBar: AppBar(title: Text(AppConfig.appName), actions: actions),
        drawer: _buildDrawer(context),
        body: child,
        floatingActionButton: floatingActionButton,
      );
    } else {
      // Desktop/Tablet layout with NavigationRail
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(context),
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                const SizedBox(height: AppConfig.spacingSmall),
                Text(
                  'Inventory Management',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          ...destinations.asMap().entries.map((entry) {
            final index = entry.key;
            final destination = entry.value;
            return ListTile(
              leading: destination.icon,
              title: Text(destination.label),
              selected: selectedIndex == index,
              onTap: () => onDestinationSelected(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: destinations.map((destination) {
        return NavigationRailDestination(icon: destination.icon, selectedIcon: destination.icon, label: Text(destination.label));
      }).toList(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
