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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters based on screen size
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < AppConfig.mobileBreakpoint;

        // Adjust card width and calculate columns
        final cardWidth = isMobile ? 160.0 : 300.0;
        final crossAxisCount = (availableWidth / (cardWidth + (isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding))).floor();
        final actualCrossAxisCount = isMobile ? 2 : crossAxisCount.clamp(1, 4); // Force 2 cols on mobile
        final allowDoubleSpan = actualCrossAxisCount >= 2;

        final tiles = <StaggeredGridTile>[];
        // Helpers to add common tiles
        void addRevenue() {
          if (permissionProvider.canManageBilling || permissionProvider.canManagePayments) {
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.totalRevenue,
                value: '₹${dashboard.monthlyProfit}',
                icon: Icons.attach_money,
                color: AppConfig.successColor,
                subtitle: 'View yearly analysis',
                onTap: () => context.push(RouteConstants.yearlyProfit),
                doubleSpan: true,
                allowDoubleSpan: allowDoubleSpan,
                trailing: Lottie.asset('assets/animations/revenue_coins.json', height: isMobile ? 100 : 140, width: isMobile ? 100 : 140),
                mainAxisCells: 2,
              ),
            );
          }
        }

        void addOrders() {
          if (permissionProvider.canManageOrders) {
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.totalOrders,
                value: dashboard.totalOrdersCurrentMonth.toString(),
                icon: Icons.shopping_cart,
                color: AppConfig.primaryColor,
                subtitle: dashboard.monthlyOrderChangePercentage >= 0
                    ? '${dashboard.formattedMonthlyOrderChangePercentage} from last month'
                    : '${dashboard.formattedMonthlyOrderChangePercentage} from last month',
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.pendingOrders,
                value: dashboard.pendingOrders.toString(),
                icon: Icons.pending,
                color: AppConfig.warningColor,
                subtitle: dashboard.pendingOrders > 0 ? UITextConstants.ordersRequireAttention : 'No orders require attention',
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
          }
        }

        void addInventoryAlerts() {
          if (permissionProvider.canManageInventory) {
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.lowStockItems,
                value: dashboard.lowStockItems.toString(),
                icon: Icons.warning,
                color: AppConfig.errorColor,
                subtitle: UITextConstants.needReorder,
                onTap: () => context.push(RouteConstants.lowStockCards),
                doubleSpan: true,
                allowDoubleSpan: allowDoubleSpan,
                trailing: Lottie.asset('assets/animations/low_stock.json', fit: BoxFit.contain),
                mainAxisCells: 2,
              ),
            );
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.outOfStock,
                value: dashboard.outOfStockItems.toString(),
                icon: Icons.remove_shopping_cart,
                color: AppConfig.errorColor,
                subtitle: UITextConstants.itemsNeedRestocking,
                onTap: () => context.push(RouteConstants.outOfStockCards),
                doubleSpan: true,
                allowDoubleSpan: allowDoubleSpan,
                trailing: Lottie.asset('assets/animations/out_of_stock.json', fit: BoxFit.contain),
                mainAxisCells: 2,
              ),
            );
          }
        }

        void addProduction() {
          if (permissionProvider.canManageProduction) {
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.productionJobs,
                value: (dashboard.pendingPrintingJobs + dashboard.pendingBoxJobs).toString(),
                icon: Icons.print,
                color: AppConfig.accentColor,
                subtitle: UITextConstants.jobsInProgress,
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
            if (isMobile) {
              tiles.add(
                _buildStatTile(
                  context,
                  title: UITextConstants.pendingPrintingJobs,
                  value: dashboard.pendingPrintingJobs.toString(),
                  icon: Icons.print,
                  color: AppConfig.accentColor,
                  subtitle: UITextConstants.jobsInPrintingQueue,
                  allowDoubleSpan: allowDoubleSpan,
                ),
              );
              tiles.add(
                _buildStatTile(
                  context,
                  title: UITextConstants.pendingBoxJobs,
                  value: dashboard.pendingBoxJobs.toString(),
                  icon: Icons.inventory_2,
                  color: AppConfig.accentColor,
                  subtitle: UITextConstants.boxOrdersInQueue,
                  allowDoubleSpan: allowDoubleSpan,
                ),
              );
            }
          }
        }

        void addFinance() {
          if (permissionProvider.canManageBilling) {
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.monthlyGrowth,
                value: dashboard.formattedMonthlyOrderChangePercentage,
                icon: Icons.trending_up,
                color: AppConfig.successColor,
                subtitle: UITextConstants.orderGrowthThisMonth,
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.pendingBills,
                value: dashboard.pendingBills.toString(),
                icon: Icons.receipt_long,
                color: AppConfig.warningColor,
                subtitle: UITextConstants.billsAwaitingPayment,
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
            tiles.add(
              _buildStatTile(
                context,
                title: UITextConstants.expenseLogging,
                value: dashboard.ordersPendingExpenseLogging.toString(),
                icon: Icons.attach_money,
                color: AppConfig.warningColor,
                subtitle: UITextConstants.ordersPendingExpenseLogging,
                allowDoubleSpan: allowDoubleSpan,
              ),
            );
          }
        }

        void addCommon() {
          tiles.add(
            _buildStatTile(
              context,
              title: UITextConstants.todaysOrders,
              value: dashboard.todaysOrders.toString(),
              icon: Icons.today,
              color: AppConfig.primaryColor,
              subtitle: UITextConstants.ordersCreatedToday,
              allowDoubleSpan: allowDoubleSpan,
            ),
          );
        }

        // Order tiles based on device
        if (isMobile) {
          addRevenue();
          addOrders();
          addInventoryAlerts();
          addCommon();
          addProduction();
          addFinance();
        } else {
          addOrders();
          addProduction();
          addInventoryAlerts();
          addRevenue();
          addCommon();
          addFinance();
        }

        return RefreshIndicator(
          onRefresh: () => dashboardProvider.fetchDashboardData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
                    right: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
                    bottom: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
                  ),
                  child: StaggeredGrid.count(
                    crossAxisCount: actualCrossAxisCount,
                    mainAxisSpacing: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
                    crossAxisSpacing: isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
                    children: tiles,
                  ),
                ),
              ),
            ],
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
    Widget? footer,
    Widget? trailing,
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: AppConfig.iconSizeLarge),
                        const Spacer(),
                        if (onTap != null)
                          Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: isMobile ? 12 : AppConfig.iconSizeSmall)
                        else
                          Icon(Icons.trending_up, color: color.withOpacity(0.5), size: isMobile ? 12 : AppConfig.iconSizeSmall),
                      ],
                    ),
                    Spacer(),
                    Text(
                      value,
                      style: ResponsiveText.getHeadline(context).copyWith(color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    if (footer != null) ...[SizedBox(height: isMobile ? 8 : AppConfig.smallPadding), footer],
                  ],
                ),
              ),
              if (trailing != null) SizedBox(width: 200, height: 150, child: trailing),
            ],
          ),
        ),
      ),
    );
  }

  StaggeredGridTile _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    VoidCallback? onTap,
    bool doubleSpan = false,
    required bool allowDoubleSpan,
    Widget? footer,
    Widget? trailing,
    int mainAxisCells = 1,
  }) {
    final card = _buildStatCard(
      context,
      title: title,
      value: value,
      icon: icon,
      color: color,
      subtitle: subtitle,
      onTap: onTap,
      footer: footer,
      trailing: trailing,
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.98, 0.98), duration: 250.ms);

    return StaggeredGridTile.count(crossAxisCellCount: doubleSpan && allowDoubleSpan ? 2 : 1, mainAxisCellCount: mainAxisCells, child: card);
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
