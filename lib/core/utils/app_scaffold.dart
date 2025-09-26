import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/providers/navigation_provider.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? pageTitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({super.key, required this.child, this.pageTitle, this.actions, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Consumer3<NavigationProvider, PermissionProvider, AuthProvider>(
      builder: (context, navigationProvider, permissionProvider, authProvider, _) {
        final destinations = NavigationItems.getDestinationsForPermissions(
          canManageOrders: permissionProvider.canManageOrders,
          canManageInventory: permissionProvider.canManageInventory,
          canManageProduction: permissionProvider.canManageProduction,
          canManageVendors: permissionProvider.canManageVendors,
          canManageSystem: permissionProvider.canManageSystem,
          canViewAuditLogs: permissionProvider.canViewAuditLogs,
          canManageBilling: permissionProvider.canManageBilling,
          canManagePayments: permissionProvider.canManagePayments,
        );

        final screenWidth = MediaQuery.of(context).size.width;

        if (screenWidth < AppConfig.mobileBreakpoint) {
          // Mobile layout with Drawer
          return Scaffold(
            appBar: AppBar(title: Text(pageTitle ?? AppConfig.appName), actions: actions),
            drawer: _buildDrawer(context, destinations, navigationProvider),
            body: child,
            floatingActionButton: floatingActionButton,
          );
        } else {
          // Desktop/Tablet layout with NavigationRail
          return Scaffold(
            body: Row(
              children: [
                _buildNavigationRail(context, destinations, navigationProvider),
                Expanded(
                  child: Column(
                    children: [
                      // _buildAppBar(context),
                      SizedBox(height: AppConfig.defaultPadding),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }

  IconData _mapLabelToLucideIcon(String label) {
    switch (label) {
      case UITextConstants.dashboard:
        return LucideIcons.home;
      case UITextConstants.orders:
        return LucideIcons.shoppingCart;
      case UITextConstants.bills:
        return LucideIcons.receipt;
      case UITextConstants.inventory:
        return LucideIcons.package;
      case UITextConstants.production:
        return LucideIcons.factory;
      case UITextConstants.vendors:
        return LucideIcons.users;
      case UITextConstants.administration:
        return LucideIcons.settings;
      default:
        return LucideIcons.home;
    }
  }

  Widget _buildDrawer(BuildContext context, List<NavigationDestination> destinations, NavigationProvider navigationProvider) {
    final safeSelectedIndex = navigationProvider.selectedIndex < destinations.length ? navigationProvider.selectedIndex : 0;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pageTitle ?? AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
                SizedBox(height: AppConfig.spacingSmall),
                Text(
                  destinations[safeSelectedIndex].label,
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
              selected: safeSelectedIndex == index,
              onTap: () => navigationProvider.setIndexOnly(index),
            );
          }),
          const Divider(),
          ListTile(leading: const Icon(LucideIcons.logOut), title: const Text('Logout'), onTap: () => _handleLogout(context)),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, List<NavigationDestination> destinations, NavigationProvider navigationProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const selectedColor = Color(0xFF1E88E5);
    final unselectedColor = colorScheme.onSurfaceVariant;

    final safeSelectedIndex = navigationProvider.selectedIndex < destinations.length ? navigationProvider.selectedIndex : 0;

    return NavigationRail(
      selectedIndex: safeSelectedIndex,
      onDestinationSelected: (index) => navigationProvider.setIndexOnly(index),
      extended: false,
      minWidth: 56,
      minExtendedWidth: 200,
      backgroundColor: colorScheme.surface,
      elevation: 2,
      groupAlignment: 0.0,
      useIndicator: true,
      indicatorColor: Colors.transparent,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelType: NavigationRailLabelType.all,
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 16, color: Colors.grey),
            IconButton(
              tooltip: 'Logout',
              icon: Icon(LucideIcons.logOut, color: unselectedColor, size: 24),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: selectedColor, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: unselectedColor),
      destinations: destinations
          .map(
            (destination) => NavigationRailDestination(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
              icon: Center(child: Icon(_mapLabelToLucideIcon(destination.label), size: 26, color: unselectedColor)),
              selectedIcon: Center(child: Icon(_mapLabelToLucideIcon(destination.label), size: 26, color: selectedColor)),
              label: Text(destination.label),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Text(pageTitle ?? AppConfig.appName, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          if (actions != null) ...actions!,
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _handleLogout(context)),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    authProvider.setContext(context);
    await authProvider.logout();
    if (context.mounted) {
      context.go(RouteConstants.login);
    }
  }
}
