import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

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
    if (mounted) context.go(RouteConstants.login);
  }

  Widget _buildDashboardContent(UserRole userRole, PermissionProvider permissionProvider) {
    return Padding(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Action Button for Order Creation flow
          if (permissionProvider.canCreate('order')) ...[_buildCreateOrderButton(), SizedBox(height: AppConfig.largePadding)],
          // Stats Cards
          Expanded(child: _isLoading ? const LoadingWidget(message: 'Loading dashboard...') : _buildStatsGrid(userRole, permissionProvider)),
        ],
      ),
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

    // Customer stats - show if user can manage orders or customers
    if (permissionProvider.canManageOrders || permissionProvider.canManageCustomers) {
      statsCards.add(
        _buildStatCard(
          title: 'Active Customers',
          value: '89',
          icon: Icons.person,
          color: AppConfig.secondaryColor,
          subtitle: 'Customers with recent orders',
        ),
      );
    }

    // System health stats - show for all users
    statsCards.add(
      _buildStatCard(title: 'System Uptime', value: '99.8%', icon: Icons.check_circle, color: AppConfig.successColor, subtitle: 'Last 30 days'),
    );

    // Recent activity stats - show for all users
    statsCards.add(
      _buildStatCard(title: 'Today\'s Orders', value: '15', icon: Icons.today, color: AppConfig.primaryColor, subtitle: 'Orders created today'),
    );

    // Inventory alerts - show if user can manage inventory
    if (permissionProvider.canManageInventory) {
      statsCards.add(
        _buildStatCard(
          title: 'Out of Stock',
          value: '3',
          icon: Icons.remove_shopping_cart,
          color: AppConfig.errorColor,
          subtitle: 'Items need restocking',
        ),
      );
    }

    // Production efficiency - show if user can manage production
    if (permissionProvider.canManageProduction) {
      statsCards.add(
        _buildStatCard(
          title: 'Production Efficiency',
          value: '94%',
          icon: Icons.speed,
          color: AppConfig.accentColor,
          subtitle: 'On-time delivery rate',
        ),
      );
    }

    // Financial metrics - show if user can manage billing
    if (permissionProvider.canManageBilling) {
      statsCards.add(
        _buildStatCard(
          title: 'Monthly Growth',
          value: '+12.5%',
          icon: Icons.trending_up,
          color: AppConfig.successColor,
          subtitle: 'Revenue growth this month',
        ),
      );
    }

    // Quality metrics - show for all users
    statsCards.add(
      _buildStatCard(title: 'Customer Satisfaction', value: '4.8/5', icon: Icons.star, color: AppConfig.warningColor, subtitle: 'Average rating'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters to maintain consistent card sizes
        final availableWidth = constraints.maxWidth;
        final cardWidth = 300.0; // Fixed card width
        final crossAxisCount = (availableWidth / (cardWidth + AppConfig.defaultPadding)).floor();
        final actualCrossAxisCount = crossAxisCount.clamp(1, 4); // Max 4 columns

        return GridView.count(
          crossAxisCount: actualCrossAxisCount,
          crossAxisSpacing: AppConfig.defaultPadding,
          mainAxisSpacing: AppConfig.defaultPadding,
          childAspectRatio: 1.2, // Fixed aspect ratio for consistent card proportions
          children: statsCards,
        );
      },
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

  Widget _buildCreateOrderButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConfig.primaryColor, AppConfig.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        boxShadow: [BoxShadow(color: AppConfig.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(RouteConstants.customerSearch),
          borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
          child: Padding(
            padding: EdgeInsets.all(AppConfig.largePadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConfig.defaultPadding),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                  child: Icon(Icons.shopping_cart, color: Colors.white, size: AppConfig.iconSizeLarge),
                ),
                SizedBox(width: AppConfig.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Order',
                        style: ResponsiveText.getTitle(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppConfig.smallPadding),
                      Text(
                        'Start the order creation process by searching for a customer',
                        style: ResponsiveText.getBody(context).copyWith(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.8), size: AppConfig.iconSizeMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
