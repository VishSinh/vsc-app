import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PermissionProvider>(
      builder: (context, authProvider, permissionProvider, child) {
        final userRole = authProvider.userRole ?? UserRole.sales;
        final destinations = _getAvailableDestinations(permissionProvider);

        return ResponsiveLayout(
          selectedIndex: _selectedIndex,
          destinations: destinations,
          onDestinationSelected: (index) => _onDestinationSelected(index, destinations),
          actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout)],
          child: _buildDashboardContent(userRole, permissionProvider),
        );
      },
    );
  }

  List<NavigationDestination> _getAvailableDestinations(PermissionProvider permissionProvider) {
    final destinations = <NavigationDestination>[const NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard')];

    // Orders - show if user can manage orders
    if (permissionProvider.canManageOrders) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Orders'));
    }

    // Inventory - show if user can manage inventory
    if (permissionProvider.canManageInventory) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.inventory), label: 'Inventory'));
    }

    // Production - show if user can manage production
    if (permissionProvider.canManageProduction) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.print), label: 'Production'));
    }

    // Administration - show if user can manage system or view audit logs
    if (permissionProvider.canManageSystem || permissionProvider.canViewAuditLogs) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Administration'));
    }

    return destinations;
  }

  void _onDestinationSelected(int index, List<NavigationDestination> destinations) {
    setState(() {
      _selectedIndex = index;
    });

    if (index >= destinations.length) return;

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        if (destinations.length > 1) {
          final secondDestination = destinations[1];
          if (secondDestination.label == 'Orders') {
            context.go('/orders');
          } else if (secondDestination.label == 'Inventory') {
            context.go('/inventory');
          } else if (secondDestination.label == 'Production') {
            context.go('/production');
          } else if (secondDestination.label == 'Administration') {
            context.go('/administration');
          }
        }
        break;
      case 2:
        if (destinations.length > 2) {
          final thirdDestination = destinations[2];
          if (thirdDestination.label == 'Inventory') {
            context.go('/inventory');
          } else if (thirdDestination.label == 'Production') {
            context.go('/production');
          } else if (thirdDestination.label == 'Administration') {
            context.go('/administration');
          }
        }
        break;
      case 3:
        if (destinations.length > 3) {
          final fourthDestination = destinations[3];
          if (fourthDestination.label == 'Production') {
            context.go('/production');
          } else if (fourthDestination.label == 'Administration') {
            context.go('/administration');
          }
        }
        break;
      case 4:
        if (destinations.length > 4) {
          context.go('/administration');
        }
        break;
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  Widget _buildDashboardContent(UserRole userRole, PermissionProvider permissionProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConfig.smallPadding),
          Text(
            'Here\'s what\'s happening with your ${userRole.value.toLowerCase()} operations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConfig.largePadding),

          // Quick Actions
          _buildQuickActions(permissionProvider),
          const SizedBox(height: AppConfig.largePadding),

          // Stats Cards
          Expanded(child: _buildStatsGrid(userRole, permissionProvider)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(PermissionProvider permissionProvider) {
    final actions = <Widget>[];

    // Register Staff - only for users who can create accounts
    if (permissionProvider.canCreate('account')) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => context.go('/register'),
          icon: const Icon(Icons.person_add),
          label: const Text('Register Staff'),
          style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: Colors.white),
        ),
      );
    }

    // Create Order - for users who can create orders
    if (permissionProvider.canCreate('order')) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => context.go('/orders/new'),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Create Order'),
          style: ElevatedButton.styleFrom(backgroundColor: AppConfig.accentColor, foregroundColor: Colors.white),
        ),
      );
    }

    // Add Inventory - for users who can create inventory
    if (permissionProvider.canCreate('inventory')) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to add inventory page
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Inventory feature coming soon!')));
          },
          icon: const Icon(Icons.add_box),
          label: const Text('Add Inventory'),
          style: ElevatedButton.styleFrom(backgroundColor: AppConfig.successColor, foregroundColor: Colors.white),
        ),
      );
    }

    // Create Production Job - for users who can create production
    if (permissionProvider.canCreate('production')) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to create production job page
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create Production Job feature coming soon!')));
          },
          icon: const Icon(Icons.print),
          label: const Text('Create Job'),
          style: ElevatedButton.styleFrom(backgroundColor: AppConfig.secondaryColor, foregroundColor: Colors.white),
        ),
      );
    }

    // Manage Vendors - for users who can manage vendors
    if (permissionProvider.canManageVendors) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => context.go('/vendors'),
          icon: const Icon(Icons.people),
          label: const Text('Manage Vendors'),
          style: ElevatedButton.styleFrom(backgroundColor: AppConfig.warningColor, foregroundColor: Colors.white),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConfig.defaultPadding),
        Wrap(spacing: AppConfig.defaultPadding, runSpacing: AppConfig.defaultPadding, children: actions),
      ],
    );
  }

  Widget _buildStatsGrid(UserRole userRole, PermissionProvider permissionProvider) {
    final statsCards = <Widget>[];

    // Orders stats - show if user can manage orders
    if (permissionProvider.canManageOrders) {
      statsCards.addAll([
        _buildStatCard(
          title: 'Total Orders',
          value: '156',
          icon: Icons.shopping_cart,
          color: AppConfig.primaryColor,
          subtitle: '+12% from last month',
        ),
        _buildStatCard(title: 'Pending Orders', value: '23', icon: Icons.pending, color: AppConfig.warningColor, subtitle: '5 require attention'),
      ]);
    }

    // Production stats - show if user can manage production
    if (permissionProvider.canManageProduction) {
      statsCards.add(
        _buildStatCard(title: 'Production Jobs', value: '8', icon: Icons.print, color: AppConfig.accentColor, subtitle: '3 in progress'),
      );
    }

    // Inventory stats - show if user can manage inventory
    if (permissionProvider.canManageInventory) {
      statsCards.add(
        _buildStatCard(title: 'Low Stock Items', value: '7', icon: Icons.warning, color: AppConfig.errorColor, subtitle: 'Need reorder'),
      );
    }

    // Revenue stats - show if user can manage billing or payments
    if (permissionProvider.canManageBilling || permissionProvider.canManagePayments) {
      statsCards.add(
        _buildStatCard(
          title: 'Total Revenue',
          value: '\$45,230',
          icon: Icons.attach_money,
          color: AppConfig.successColor,
          subtitle: '+8% from last month',
        ),
      );
    }

    // Partners stats - show if user can manage vendors
    if (permissionProvider.canManageVendors) {
      statsCards.add(
        _buildStatCard(title: 'Active Partners', value: '12', icon: Icons.people, color: AppConfig.secondaryColor, subtitle: '3 new this month'),
      );
    }

    return GridView.count(
      crossAxisCount: _getGridCrossAxisCount(),
      crossAxisSpacing: AppConfig.defaultPadding,
      mainAxisSpacing: AppConfig.defaultPadding,
      childAspectRatio: 1.5,
      children: statsCards,
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, required String subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Icon(Icons.trending_up, color: color.withOpacity(0.5), size: 16),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: AppConfig.smallPadding),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppConfig.smallPadding),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  int _getGridCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < AppConfig.mobileBreakpoint) {
      return 1;
    } else if (screenWidth < AppConfig.tabletBreakpoint) {
      return 2;
    } else {
      return 3;
    }
  }
}
