import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';

import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/dashboard_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    // Check if permissions are loaded, if not show loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionProvider = context.read<PermissionProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      dashboardProvider.setLoading(true);

      if (!permissionProvider.isInitialized) {
        // Wait for permissions to load
        permissionProvider
            .initializePermissions()
            .then((_) {
              if (mounted) {
                // After permissions load, fetch dashboard data
                dashboardProvider.fetchDashboardData();
              }
            })
            .catchError((error) {
              if (mounted) {
                dashboardProvider.setLoading(false);
              }
            });
      } else {
        // Permissions already loaded, fetch dashboard data
        dashboardProvider.fetchDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, PermissionProvider, DashboardProvider>(
      builder: (context, authProvider, permissionProvider, dashboardProvider, child) {
        final userRole = authProvider.userRole ?? UserRole.sales;
        return _buildDashboardContent(userRole, permissionProvider, dashboardProvider);
      },
    );
  }

  Widget _buildDashboardContent(UserRole userRole, PermissionProvider permissionProvider, DashboardProvider dashboardProvider) {
    final isMobile = MediaQuery.of(context).size.width < AppConfig.mobileBreakpoint;

    return Padding(
      padding: EdgeInsets.all(isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Action Button for Order Creation flow
          if (permissionProvider.canCreate('order')) ...[
            _buildCreateOrderButton(context),
            SizedBox(height: isMobile ? AppConfig.defaultPadding : AppConfig.largePadding),
          ],
          // Stats Cards
          Expanded(child: _buildStatsGrid(userRole, permissionProvider, dashboardProvider)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserRole userRole, PermissionProvider permissionProvider, DashboardProvider dashboardProvider) {
    final statsCards = <Widget>[];
    final dashboard = dashboardProvider.dashboardData;

    // If still loading with no data, show loading indicator
    if (dashboard == null && dashboardProvider.isLoading) {
      return const Center(child: LoadingWidget(message: 'Loading dashboard...'));
    }

    // If no dashboard data is available and not loading, just show pull-to-refresh
    if (dashboard == null) {
      return RefreshIndicator(
        onRefresh: () => dashboardProvider.fetchDashboardData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [SizedBox(height: MediaQuery.of(context).size.height * 0.7)],
        ),
      );
    }

    // Orders stats - show if user can manage orders
    if (permissionProvider.canManageOrders) {
      statsCards.addAll([
        _buildStatCard(
          context,
          title: UITextConstants.totalOrders,
          value: dashboard.totalOrdersCurrentMonth.toString(),
          icon: Icons.shopping_cart,
          color: AppConfig.primaryColor,
          subtitle: dashboard.monthlyOrderChangePercentage >= 0
              ? '${dashboard.formattedMonthlyOrderChangePercentage} from last month'
              : '${dashboard.formattedMonthlyOrderChangePercentage} from last month',
        ),
        _buildStatCard(
          context,
          title: UITextConstants.pendingOrders,
          value: dashboard.pendingOrders.toString(),
          icon: Icons.pending,
          color: AppConfig.warningColor,
          subtitle: dashboard.pendingOrders > 0 ? UITextConstants.ordersRequireAttention : 'No orders require attention',
        ),
      ]);
    }

    // Production stats - show if user can manage production
    if (permissionProvider.canManageProduction) {
      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.productionJobs,
          value: (dashboard.pendingPrintingJobs + dashboard.pendingBoxJobs).toString(),
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
          context,
          title: UITextConstants.lowStockItems,
          value: dashboard.lowStockItems.toString(),
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
          context,
          title: UITextConstants.totalRevenue,
          value: '₹${dashboard.monthlyProfit}',
          icon: Icons.attach_money,
          color: AppConfig.successColor,
          subtitle: 'View yearly analysis',
          onTap: () => context.push(RouteConstants.yearlyProfit),
        ),
      );
    }

    // Recent activity stats - show for all users
    statsCards.add(
      _buildStatCard(
        context,
        title: UITextConstants.todaysOrders,
        value: dashboard.todaysOrders.toString(),
        icon: Icons.today,
        color: AppConfig.primaryColor,
        subtitle: UITextConstants.ordersCreatedToday,
      ),
    );

    // Inventory alerts - show if user can manage inventory
    if (permissionProvider.canManageInventory) {
      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.outOfStock,
          value: dashboard.outOfStockItems.toString(),
          icon: Icons.remove_shopping_cart,
          color: AppConfig.errorColor,
          subtitle: UITextConstants.itemsNeedRestocking,
        ),
      );
    }

    // Production efficiency - show if user can manage production
    if (permissionProvider.canManageProduction) {
      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.pendingPrintingJobs,
          value: dashboard.pendingPrintingJobs.toString(),
          icon: Icons.print,
          color: AppConfig.accentColor,
          subtitle: UITextConstants.jobsInPrintingQueue,
        ),
      );

      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.pendingBoxJobs,
          value: dashboard.pendingBoxJobs.toString(),
          icon: Icons.inventory_2,
          color: AppConfig.accentColor,
          subtitle: UITextConstants.boxOrdersInQueue,
        ),
      );
    }

    // Financial metrics - show if user can manage billing
    if (permissionProvider.canManageBilling) {
      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.monthlyGrowth,
          value: dashboard.formattedMonthlyOrderChangePercentage,
          icon: Icons.trending_up,
          color: AppConfig.successColor,
          subtitle: UITextConstants.orderGrowthThisMonth,
        ),
      );

      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.pendingBills,
          value: dashboard.pendingBills.toString(),
          icon: Icons.receipt_long,
          color: AppConfig.warningColor,
          subtitle: UITextConstants.billsAwaitingPayment,
        ),
      );
    }

    // Expense logging metrics - show for finance users
    if (permissionProvider.canManageBilling) {
      statsCards.add(
        _buildStatCard(
          context,
          title: UITextConstants.expenseLogging,
          value: dashboard.ordersPendingExpenseLogging.toString(),
          icon: Icons.attach_money,
          color: AppConfig.warningColor,
          subtitle: UITextConstants.ordersPendingExpenseLogging,
        ),
      );
    }
    ;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters based on screen size
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < AppConfig.mobileBreakpoint;

        // Adjust card width and aspect ratio based on screen size
        final cardWidth = isMobile ? 160.0 : 300.0;
        final childAspectRatio = isMobile ? 1.0 : 1.2;

        // Calculate cross axis count
        final crossAxisCount = (availableWidth / (cardWidth + (isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding))).floor();
        final actualCrossAxisCount = crossAxisCount.clamp(1, 4); // Max 4 columns

        return RefreshIndicator(
          onRefresh: () => dashboardProvider.fetchDashboardData(),
          child: GridView.count(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures scroll works even when content fits screen
            crossAxisCount: actualCrossAxisCount,
            crossAxisSpacing: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
            mainAxisSpacing: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
            childAspectRatio: childAspectRatio,
            children: statsCards,
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width < AppConfig.mobileBreakpoint;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 8 : AppConfig.defaultRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8 : AppConfig.defaultRadius),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: isMobile ? AppConfig.iconSizeSmall : AppConfig.iconSizeMedium),
                  Spacer(),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: isMobile ? 12 : AppConfig.iconSizeSmall)
                  else
                    Icon(Icons.trending_up, color: color.withOpacity(0.5), size: isMobile ? 12 : AppConfig.iconSizeSmall),
                ],
              ),
              Spacer(),
              Text(
                value,
                style: isMobile
                    ? ResponsiveText.getTitle(context).copyWith(color: color, fontWeight: FontWeight.bold)
                    : ResponsiveText.getHeadline(context).copyWith(color: color),
              ),
              SizedBox(height: isMobile ? 4 : AppConfig.smallPadding),
              Text(
                title,
                style: isMobile ? ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500) : ResponsiveText.getTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 2 : AppConfig.smallPadding),
              Text(
                subtitle,
                style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.grey600, fontSize: isMobile ? 10 : null),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOrderButton(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppConfig.mobileBreakpoint;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConfig.primaryColor, AppConfig.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : AppConfig.defaultRadius),
        boxShadow: [BoxShadow(color: AppConfig.primaryColor.withOpacity(0.3), blurRadius: isMobile ? 6 : 10, offset: Offset(0, isMobile ? 2 : 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(RouteConstants.customerSearch),
          borderRadius: BorderRadius.circular(isMobile ? 8 : AppConfig.defaultRadius),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? AppConfig.defaultPadding : AppConfig.largePadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : AppConfig.defaultRadius),
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.white, size: isMobile ? AppConfig.iconSizeMedium : AppConfig.iconSizeLarge),
                ),
                SizedBox(width: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UITextConstants.createOrder,
                        style: isMobile
                            ? ResponsiveText.getBody(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                            : ResponsiveText.getTitle(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: isMobile ? 2 : AppConfig.smallPadding),
                      Text(
                        isMobile ? UITextConstants.searchCustomer : UITextConstants.orderCreationSubtitle,
                        style: isMobile
                            ? ResponsiveText.getCaption(context).copyWith(color: Colors.white.withOpacity(0.9))
                            : ResponsiveText.getBody(context).copyWith(color: Colors.white.withOpacity(0.9)),
                        maxLines: isMobile ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.8), size: isMobile ? 16 : AppConfig.iconSizeMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
