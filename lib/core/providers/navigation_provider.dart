import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  String _currentPage = 'dashboard';

  int get selectedIndex => _selectedIndex;
  String get currentPage => _currentPage;

  /// Get destinations based on current permissions
  List<NavigationDestination> _getDestinations(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    return NavigationItems.getDestinationsForPermissions(
      canViewOrders: permissionProvider.canManageOrders,
      canViewInventory: permissionProvider.canManageInventory,
      canViewProduction: permissionProvider.canManageProduction,
      canViewVendors: permissionProvider.canManageVendors,
      canViewSystem: permissionProvider.canManageSystem,
      canViewAuditLogs: permissionProvider.canViewAuditLogs,
      canViewBilling: permissionProvider.canManageBilling,
      canViewPayments: permissionProvider.canManagePayments,
    );
  }

  /// Set the selected index and handle navigation
  void setSelectedIndex(int index, BuildContext context) {
    if (_selectedIndex == index) return;

    _selectedIndex = index;
    _updateCurrentPage(index, context);
    _navigateToDestination(context, index);
    notifyListeners();
  }

  /// Set the selected index without navigation (for drawer/rail navigation)
  void setIndexOnly(int index) {
    if (_selectedIndex == index) return;

    _selectedIndex = index;
    notifyListeners();
  }

  /// Update current page based on selected index
  void _updateCurrentPage(int index, BuildContext context) {
    final destinations = _getDestinations(context);
    final route = NavigationItems.getRouteForIndex(index, destinations);
    _currentPage = route.replaceAll('/', '');
  }

  /// Navigate to destination based on index
  void _navigateToDestination(BuildContext context, int index) {
    final destinations = _getDestinations(context);
    final route = NavigationItems.getRouteForIndex(index, destinations);

    context.go(route);
  }

  /// Navigate to a specific route and update selected index
  void navigateToRoute(BuildContext context, String route) {
    final destinations = _getDestinations(context);
    final index = _getIndexForRoute(route, destinations);

    if (index != -1) {
      setSelectedIndex(index, context);
    } else {
      // Handle custom routes that aren't in main navigation
      context.go(route);
    }
  }

  /// Get index for a specific route
  int _getIndexForRoute(String route, List<NavigationDestination> destinations) {
    for (int i = 0; i < destinations.length; i++) {
      final destinationRoute = NavigationItems.getRouteForIndex(i, destinations);
      if (destinationRoute == route) {
        return i;
      }
    }
    return -1;
  }

  /// Clear navigation stack and go to dashboard
  void clearStackAndGoToDashboard(BuildContext context) {
    _selectedIndex = 0;
    _currentPage = 'dashboard';
    context.go(RouteConstants.dashboard);
    notifyListeners();
  }

  /// Go back to previous page
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // If can't pop, go to dashboard
      clearStackAndGoToDashboard(context);
    }
  }

  /// Initialize navigation state based on page name
  void initializeNavigationForPage(String pageName, BuildContext context) {
    final destinations = _getDestinations(context);
    final index = NavigationItems.getSelectedIndexForPage(pageName, destinations);

    if (index != -1) {
      _selectedIndex = index;
      _updateCurrentPage(index, context);
    }
  }

  /// Initialize navigation state based on current route
  void initializeNavigationForRoute(String route, BuildContext context) {
    AppLogger.debug('NavigationProvider: initializeNavigationForRoute called with route: $route');
    final destinations = _getDestinations(context);
    final index = _getIndexForRoute(route, destinations);

    AppLogger.debug('NavigationProvider: Found index: $index for route: $route');
    AppLogger.debug('NavigationProvider: Available destinations: ${destinations.map((d) => d.label).toList()}');

    if (index != -1) {
      _selectedIndex = index;
      _updateCurrentPage(index, context);
      AppLogger.debug('NavigationProvider: Set selectedIndex to $index');
      notifyListeners();
    } else if (route == RouteConstants.dashboard) {
      // If we can't find the route but it's dashboard, default to index 0
      _selectedIndex = 0;
      _currentPage = 'dashboard';
      AppLogger.debug('NavigationProvider: Defaulting to dashboard (index 0)');
      notifyListeners();
    }
  }
}
