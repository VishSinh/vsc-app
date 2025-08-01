import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/widgets/shimmer_widgets.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/snackbar_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isLoading = true; // Show shimmer while permissions load

  @override
  void initState() {
    super.initState();
    // Check if permissions are loaded, if not show shimmer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionProvider = context.read<PermissionProvider>();
      if (!permissionProvider.isInitialized) {
        // Show shimmer while permissions load
        setState(() {
          _isLoading = true;
        });

        // Wait for permissions to load
        permissionProvider
            .initializePermissions()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
      } else {
        // Permissions already loaded, hide shimmer
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PermissionProvider>(
      builder: (context, authProvider, permissionProvider, child) {
        final userRole = authProvider.userRole ?? UserRole.sales;
        final destinations = NavigationItems.getDestinationsForPermissions(
          canManageOrders: permissionProvider.canManageOrders,
          canManageInventory: permissionProvider.canManageInventory,
          canManageProduction: permissionProvider.canManageProduction,
          canManageVendors: permissionProvider.canManageVendors,
          canManageSystem: permissionProvider.canManageSystem,
          canViewAuditLogs: permissionProvider.canViewAuditLogs,
        );

        return ResponsiveLayout(
          selectedIndex: _selectedIndex,
          destinations: destinations,
          onDestinationSelected: (index) => _onDestinationSelected(index, destinations),
          actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout)],
          pageTitle: UITextConstants.dashboard,
          child: _buildDashboardContent(userRole, permissionProvider),
        );
      },
    );
  }

  void _onDestinationSelected(int index, List<NavigationDestination> destinations) {
    setState(() {
      _selectedIndex = index;
    });

    if (index >= destinations.length) return;

    final route = NavigationItems.getRouteForIndex(index, destinations);
    if (route != '/') {
      context.go(route);
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.setContext(context);
    await authProvider.logout();
    if (mounted) {
      context.go(RouteConstants.login);
    }
  }

  Widget _buildDashboardContent(UserRole userRole, PermissionProvider permissionProvider) {
    return Padding(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role-based subtitle

          // Quick Actions
          _buildQuickActions(permissionProvider),
          SizedBox(height: AppConfig.largePadding),

          // Stats Cards
          Expanded(child: _isLoading ? _buildShimmerSkeleton() : _buildStatsGrid(userRole, permissionProvider)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(PermissionProvider permissionProvider) {
    final actions = <Widget>[];

    // Register Staff - only for users who can create accounts
    if (permissionProvider.canCreate('account')) {
      actions.add(
        ButtonUtils.primaryButton(onPressed: () => context.go(RouteConstants.register), label: UITextConstants.registerStaff, icon: Icons.person_add),
      );
    }

    // Create Order - for users who can create orders
    if (permissionProvider.canCreate('order')) {
      actions.add(
        ButtonUtils.accentButton(
          onPressed: () => context.go(RouteConstants.newOrder),
          label: UITextConstants.createOrder,
          icon: Icons.add_shopping_cart,
        ),
      );
    }

    // Add Inventory - for users who can create inventory
    if (permissionProvider.canCreate('inventory')) {
      actions.add(
        ButtonUtils.successButton(
          onPressed: () {
            // TODO: Navigate to add inventory page
            SnackbarUtils.showInfo(context, SnackbarConstants.addInventoryComingSoon);
          },
          label: UITextConstants.addInventory,
          icon: Icons.add_box,
        ),
      );
    }

    // Create Production Job - for users who can create production
    if (permissionProvider.canCreate('production')) {
      actions.add(
        ButtonUtils.secondaryButton(
          onPressed: () {
            // TODO: Navigate to create production job page
            SnackbarUtils.showInfo(context, SnackbarConstants.createProductionJobComingSoon);
          },
          label: UITextConstants.createJob,
          icon: Icons.print,
        ),
      );
    }

    // Manage Vendors - for users who can manage vendors
    if (permissionProvider.canManageVendors) {
      actions.add(
        ButtonUtils.warningButton(onPressed: () => context.go(RouteConstants.vendors), label: UITextConstants.manageVendors, icon: Icons.people),
      );
    }

    // Create Card - for users who can manage inventory
    if (permissionProvider.canManageInventory) {
      actions.add(
        ButtonUtils.successButton(onPressed: () => context.go(RouteConstants.createCard), label: UITextConstants.createCard, icon: Icons.credit_card),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(UITextConstants.quickActions, style: ResponsiveText.getTitle(context)),
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
          title: UITextConstants.totalOrders,
          value: '156',
          icon: Icons.shopping_cart,
          color: AppConfig.primaryColor,
          subtitle: UITextConstants.ordersFromLastMonth,
        ),
        _buildStatCard(
          title: UITextConstants.pendingOrders,
          value: '23',
          icon: Icons.pending,
          color: AppConfig.warningColor,
          subtitle: UITextConstants.ordersRequireAttention,
        ),
      ]);
    }

    // Production stats - show if user can manage production
    if (permissionProvider.canManageProduction) {
      statsCards.add(
        _buildStatCard(
          title: UITextConstants.productionJobs,
          value: '8',
          icon: Icons.print,
          color: AppConfig.accentColor,
          subtitle: UITextConstants.jobsInProgress,
        ),
      );
    }

    // Inventory stats - show if user can manage inventory
    if (permissionProvider.canManageInventory) {
      statsCards.add(
        _buildStatCard(
          title: UITextConstants.lowStockItems,
          value: '7',
          icon: Icons.warning,
          color: AppConfig.errorColor,
          subtitle: UITextConstants.needReorder,
        ),
      );
    }

    // Revenue stats - show if user can manage billing or payments
    if (permissionProvider.canManageBilling || permissionProvider.canManagePayments) {
      statsCards.add(
        _buildStatCard(
          title: UITextConstants.totalRevenue,
          value: '\$45,230',
          icon: Icons.attach_money,
          color: AppConfig.successColor,
          subtitle: UITextConstants.revenueFromLastMonth,
        ),
      );
    }

    // Partners stats - show if user can manage vendors
    if (permissionProvider.canManageVendors) {
      statsCards.add(
        _buildStatCard(
          title: UITextConstants.activePartners,
          value: '12',
          icon: Icons.people,
          color: AppConfig.secondaryColor,
          subtitle: UITextConstants.newPartnersThisMonth,
        ),
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
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppConfig.iconSizeMedium),
                Spacer(),
                Icon(Icons.trending_up, color: color.withOpacity(0.5), size: AppConfig.iconSizeSmall),
              ],
            ),
            Spacer(),
            Text(value, style: ResponsiveText.getHeadline(context).copyWith(color: color)),
            SizedBox(height: AppConfig.smallPadding),
            Text(title, style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.smallPadding),
            Text(subtitle, style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.grey600)),
          ],
        ),
      ),
    );
  }

  int _getGridCrossAxisCount() {
    return context.gridCrossAxisCount;
  }

  Widget _buildShimmerSkeleton() {
    return GridView.count(
      crossAxisCount: context.gridCrossAxisCount,
      crossAxisSpacing: AppConfig.defaultPadding,
      mainAxisSpacing: AppConfig.defaultPadding,
      childAspectRatio: context.gridChildAspectRatio,
      children: List.generate(6, (index) {
        return const ShimmerWrapper(child: StatsCardSkeleton());
      }),
    );
  }
}
