import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/services/navigation_service.dart';
import 'package:vsc_app/core/services/auth_service.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/auth/presentation/pages/login_page.dart';
import 'package:vsc_app/features/auth/presentation/pages/dashboard_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/orders_page.dart';
import 'package:vsc_app/features/inventory/presentation/pages/inventory_page.dart';
import 'package:vsc_app/features/production/presentation/pages/production_page.dart';
import 'package:vsc_app/features/administration/presentation/pages/administration_page.dart';
import 'package:vsc_app/features/auth/presentation/pages/register_page.dart';
import 'package:vsc_app/features/vendors/presentation/pages/vendors_page.dart';
import 'package:vsc_app/features/cards/presentation/pages/create_card_page.dart';

class AppRouter {
  static late final GoRouter router;

  static void initialize() {
    router = GoRouter(
      initialLocation: RouteConstants.login,
      redirect: (context, state) async {
        final authService = AuthService();
        final isLoggedIn = await authService.isLoggedIn();

        // If user is not logged in and trying to access protected routes
        if (!isLoggedIn && state.matchedLocation != RouteConstants.login) {
          return RouteConstants.login;
        }

        // If user is logged in and on login page, redirect to dashboard
        if (isLoggedIn && state.matchedLocation == RouteConstants.login) {
          return RouteConstants.dashboard;
        }

        return null;
      },
      routes: [
        GoRoute(path: RouteConstants.login, name: RouteConstants.loginRouteName, builder: (context, state) => const LoginPage()),
        GoRoute(path: RouteConstants.dashboard, name: RouteConstants.dashboardRouteName, builder: (context, state) => const DashboardPage()),
        GoRoute(path: RouteConstants.orders, name: RouteConstants.ordersRouteName, builder: (context, state) => const OrdersPage()),
        GoRoute(path: RouteConstants.newOrder, name: RouteConstants.newOrderRouteName, builder: (context, state) => const OrdersPage()),
        GoRoute(path: RouteConstants.inventory, name: RouteConstants.inventoryRouteName, builder: (context, state) => const InventoryPage()),
        GoRoute(path: RouteConstants.production, name: RouteConstants.productionRouteName, builder: (context, state) => const ProductionPage()),
        GoRoute(
          path: RouteConstants.administration,
          name: RouteConstants.administrationRouteName,
          builder: (context, state) => const AdministrationPage(),
        ),
        GoRoute(path: RouteConstants.vendors, name: RouteConstants.vendorsRouteName, builder: (context, state) => const VendorsPage()),
        GoRoute(path: RouteConstants.createCard, name: RouteConstants.createCardRouteName, builder: (context, state) => const CreateCardPage()),

        // Register route (Admin only)
        GoRoute(path: RouteConstants.register, name: RouteConstants.registerRouteName, builder: (context, state) => const RegisterPage()),
      ],
    );

    // Set the router in the navigation service
    NavigationService.setRouter(router);
  }
}
