import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/services/navigation_service.dart';
import 'package:vsc_app/core/services/auth_service.dart';
import 'package:vsc_app/features/auth/presentation/pages/login_page.dart';
import 'package:vsc_app/features/auth/presentation/pages/dashboard_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/orders_page.dart';
import 'package:vsc_app/features/inventory/presentation/pages/inventory_page.dart';
import 'package:vsc_app/features/production/presentation/pages/production_page.dart';
import 'package:vsc_app/features/administration/presentation/pages/administration_page.dart';
import 'package:vsc_app/features/auth/presentation/pages/register_page.dart';
import 'package:vsc_app/features/vendors/presentation/pages/vendors_page.dart';

class AppRouter {
  static late final GoRouter router;
  
  static void initialize() {
    router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) async {
        final authService = AuthService();
        final isLoggedIn = await authService.isLoggedIn();
        
        // If user is not logged in and trying to access protected routes
        if (!isLoggedIn && state.matchedLocation != '/login') {
          return '/login';
        }
        
        // If user is logged in and on login page, redirect to dashboard
        if (isLoggedIn && state.matchedLocation == '/login') {
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: '/orders/new',
          name: 'new-order',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/production',
          name: 'production',
          builder: (context, state) => const ProductionPage(),
        ),
        GoRoute(
          path: '/administration',
          name: 'administration',
          builder: (context, state) => const AdministrationPage(),
        ),
        GoRoute(
          path: '/vendors',
          name: 'vendors',
          builder: (context, state) => const VendorsPage(),
        ),
        
        // Register route (Admin only)
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
    
    // Set the router in the navigation service
    NavigationService.setRouter(router);
  }
} 