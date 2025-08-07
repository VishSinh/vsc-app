import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';

class NavigationItems {
  // All available navigation destinations
  static const List<NavigationDestination> allDestinations = [
    NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard),
    NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders),
    NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory),
    NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production),
    NavigationDestination(icon: Icon(Icons.people), label: UITextConstants.vendors),
    NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration),
  ];

  // Get destinations based on permissions
  static List<NavigationDestination> getDestinationsForPermissions({
    required bool canManageOrders,
    required bool canManageInventory,
    required bool canManageProduction,
    required bool canManageVendors,
    required bool canManageSystem,
    required bool canViewAuditLogs,
    required bool canManageBilling,
    required bool canManagePayments,
  }) {
    final destinations = <NavigationDestination>[const NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard)];

    if (canManageOrders) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders));
    }
    if (canManageBilling || canManagePayments) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.receipt_long), label: UITextConstants.bills));
    }

    if (canManageInventory) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory));
    }

    if (canManageProduction) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production));
    }

    if (canManageVendors) {
      destinations.add(const NavigationDestination(icon: Icon(Icons.people), label: UITextConstants.vendors));
    }

    if (canManageSystem || canViewAuditLogs) {
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
