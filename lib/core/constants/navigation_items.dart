import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/create_card_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';

class NavigationItems {
  // Get floating action button for a specific page
  static Widget? getFloatingActionButtonForPage(String pageName, BuildContext context) {
    switch (pageName.toLowerCase()) {
      case 'inventory':
        return Consumer<PermissionProvider>(
          builder: (context, permissionProvider, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: () {
                        final cardProvider = context.read<CardListProvider>();
                        cardProvider.loadCards();
                      },
                      backgroundColor: Colors.orange,
                      heroTag: 'reload_inventory',
                      mini: true,
                      child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                    ),
                  ),

                  const SizedBox(height: 8),
                  if (permissionProvider.canCreate('card'))
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        onPressed: () {
                          final createCardProvider = CreateCardProvider();
                          context.push(RouteConstants.createCard, extra: createCardProvider);
                        },
                        backgroundColor: AppConfig.primaryColor,
                        heroTag: 'add_card',
                        mini: true,
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      case 'orders':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    final orderProvider = context.read<OrderListProvider>();
                    orderProvider.fetchOrders();
                  },
                  backgroundColor: Colors.orange,
                  heroTag: 'reload_orders',
                  mini: true,
                  child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                ),
              ),

              const SizedBox(height: 8),
              Consumer<PermissionProvider>(
                builder: (context, permissionProvider, _) {
                  if (!permissionProvider.canCreate('order')) return const SizedBox.shrink();
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: () => context.go(RouteConstants.customerSearch),
                      backgroundColor: AppConfig.primaryColor,
                      heroTag: 'add_order',
                      mini: true,
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      default:
        return null;
    }
  }

  // Get destinations based on permissions
  static List<NavigationDestination> getDestinationsForPermissions({
    required bool canViewOrders,
    required bool canViewInventory,
    required bool canViewProduction,
    required bool canViewVendors,
    required bool canViewSystem,
    required bool canViewAuditLogs,
    required bool canViewBilling,
    required bool canViewPayments,
  }) {
    final destinations = <NavigationDestination>[const NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard)];

    if (canViewOrders) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders));
    }
    if (canViewBilling || canViewPayments) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.receipt_long), label: UITextConstants.bills));
    }

    if (canViewInventory) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory));
    }

    // if (canManageProduction) {
    //   destinations.add(const NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production));
    // }

    // if (canManageVendors) {
    //   destinations.add(const NavigationDestination(icon: Icon(Icons.people), label: UITextConstants.vendors));
    // }

    if (canViewSystem || canViewAuditLogs) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration));
    }

    return destinations;
  }

  // Get selected index for a specific page
  static int getSelectedIndexForPage(String pageName, List<NavigationDestination> destinations) {
    switch (pageName) {
      case 'dashboard':
        return 0;
      case 'orders':
        return destinations.indexWhere((d) => d.label == UITextConstants.orders);
      case 'bills':
        return destinations.indexWhere((d) => d.label == UITextConstants.bills);
      case 'inventory':
        return destinations.indexWhere((d) => d.label == UITextConstants.inventory);
      case 'production':
        return destinations.indexWhere((d) => d.label == UITextConstants.production);
      case 'vendors':
        return destinations.indexWhere((d) => d.label == UITextConstants.vendors);
      case 'administration':
        return destinations.indexWhere((d) => d.label == UITextConstants.administration);
      default:
        return 0;
    }
  }

  // Get route for destination index
  static String getRouteForIndex(int index, List<NavigationDestination> destinations) {
    if (index >= destinations.length) return RouteConstants.dashboard;

    final destination = destinations[index];
    switch (destination.label) {
      case UITextConstants.dashboard:
        return RouteConstants.dashboard;
      case UITextConstants.orders:
        return RouteConstants.orders;
      case UITextConstants.bills:
        return RouteConstants.bills;
      case UITextConstants.inventory:
        return RouteConstants.inventory;
      case UITextConstants.production:
        return RouteConstants.production;
      case UITextConstants.vendors:
        return RouteConstants.vendors;
      case UITextConstants.administration:
        return RouteConstants.administration;
      default:
        return RouteConstants.dashboard;
    }
  }
}
