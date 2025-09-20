import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/providers/navigation_provider.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';

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
      },
    );
  }

  Widget _buildDrawer(BuildContext context, List<NavigationDestination> destinations, NavigationProvider navigationProvider) {
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
                  destinations[navigationProvider.selectedIndex].label,
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
              selected: navigationProvider.selectedIndex == index,
              onTap: () => navigationProvider.setIndexOnly(index),
            );
          }),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () => _handleLogout(context)),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, List<NavigationDestination> destinations, NavigationProvider navigationProvider) {
    return NavigationRail(
      selectedIndex: navigationProvider.selectedIndex,
      onDestinationSelected: (index) => navigationProvider.setIndexOnly(index),
      labelType: NavigationRailLabelType.all,
      destinations: destinations
          .map((destination) => NavigationRailDestination(icon: destination.icon, selectedIcon: destination.icon, label: Text(destination.label)))
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
