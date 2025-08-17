import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/utils/app_scaffold.dart';
import 'package:vsc_app/core/providers/navigation_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/home/presentation/pages/dashboard_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/orders_page.dart';
import 'package:vsc_app/features/cards/presentation/pages/inventory_page.dart';
import 'package:vsc_app/features/production/presentation/pages/production_page.dart';
import 'package:vsc_app/features/administration/presentation/pages/administration_page.dart';
import 'package:vsc_app/features/vendors/presentation/pages/vendors_page.dart';
import 'package:vsc_app/features/bills/presentation/pages/bill_search_page.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _initializeNavigation();
      }
    });
  }

  void _initializeNavigation() {
    final navigationProvider = context.read<NavigationProvider>();
    final currentRoute = GoRouterState.of(context).uri.toString();
    navigationProvider.initializeNavigationForRoute(currentRoute, context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, PermissionProvider>(
      builder: (context, navigationProvider, permissionProvider, _) {
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

        // Get the current page based on selected index
        final currentPage = _getCurrentPage(navigationProvider.selectedIndex, destinations);
        final pageTitle = destinations[navigationProvider.selectedIndex].label;

        // Get the floating action button for the current page
        final floatingActionButton = NavigationItems.getFloatingActionButtonForPage(pageTitle.toLowerCase(), context);

        return AppScaffold(pageTitle: pageTitle, floatingActionButton: floatingActionButton, child: currentPage);
      },
    );
  }

  Widget _getCurrentPage(int selectedIndex, List<NavigationDestination> destinations) {
    // Map the selected index to the corresponding page
    // This ensures we only show pages that the user has permission to see
    final availablePages = <Widget>[];

    for (int i = 0; i < destinations.length; i++) {
      switch (destinations[i].label.toLowerCase()) {
        case 'dashboard':
          availablePages.add(const DashboardPage());
          break;
        case 'orders':
          availablePages.add(const OrdersPage());
          break;
        case 'products':
        case 'inventory':
          availablePages.add(const InventoryPage());
          break;
        case 'production':
          availablePages.add(const ProductionPage());
          break;
        case 'vendors':
          availablePages.add(const VendorsPage());
          break;
        case 'bills':
          availablePages.add(const BillSearchPage());
          break;
        case 'administration':
          availablePages.add(const AdministrationPage());
          break;
        default:
          // Fallback to dashboard for unknown destinations
          availablePages.add(const DashboardPage());
          break;
      }
    }

    // Return the page at the selected index, or dashboard as fallback
    if (selectedIndex < availablePages.length) {
      return availablePages[selectedIndex];
    }

    return const DashboardPage();
  }
}
