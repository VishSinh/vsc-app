import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/services/navigation_service.dart';
import 'package:vsc_app/features/home/data/services/auth_service.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/home/presentation/pages/login_page.dart';
import 'package:vsc_app/core/utils/main_layout.dart';
import 'package:vsc_app/features/home/presentation/pages/register_page.dart';
import 'package:vsc_app/features/vendors/presentation/pages/vendor_detail_page.dart';
import 'package:vsc_app/features/cards/presentation/pages/card_detail_page.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/cards/presentation/pages/create_card_page.dart';
import 'package:vsc_app/features/cards/presentation/providers/create_card_provider.dart';
import 'package:vsc_app/features/cards/presentation/pages/similar_cards_page.dart';
import 'package:vsc_app/features/cards/presentation/pages/bluetooth_print_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/create_order_customer_search_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/create_order_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/create_order_review_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/order_detail_page.dart';
import 'package:vsc_app/features/orders/presentation/pages/edit_order_page.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/bills/presentation/pages/bill_page.dart';
import 'package:vsc_app/features/home/presentation/pages/yearly_profit_page.dart';
import 'package:vsc_app/features/home/presentation/pages/yearly_sale_page.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/home/presentation/pages/low_stock_cards_page.dart';
import 'package:vsc_app/features/home/presentation/pages/out_of_stock_cards_page.dart';
import 'package:vsc_app/features/home/presentation/pages/todays_orders_page.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/staff_provider.dart';
import 'package:vsc_app/features/administration/presentation/pages/audit_model_logs_page.dart';
import 'package:vsc_app/features/administration/presentation/pages/staff_management_page.dart';
import 'package:vsc_app/features/administration/presentation/pages/api_logs_page.dart';
import 'package:vsc_app/features/bills/presentation/pages/bill_print_preview_page.dart';

class AppRouter {
  static late final GoRouter router;
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static void initialize() {
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
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
        GoRoute(
          path: RouteConstants.dashboard,
          name: RouteConstants.dashboardRouteName,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(path: RouteConstants.orders, name: RouteConstants.ordersRouteName, builder: (context, state) => const MainLayout()),
        GoRoute(path: RouteConstants.bills, name: RouteConstants.billsRouteName, builder: (context, state) => const MainLayout()),
        GoRoute(
          path: RouteConstants.newOrder,
          name: RouteConstants.newOrderRouteName,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: RouteConstants.inventory,
          name: RouteConstants.inventoryRouteName,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: RouteConstants.billDetail,
          name: RouteConstants.billDetailRouteName,
          builder: (context, state) {
            final billId = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;
            final fromOrderCreation = extra?['fromOrderCreation'] as bool? ?? false;
            return BillPage(billId: billId, fromOrderCreation: fromOrderCreation);
          },
        ),
        GoRoute(
          path: RouteConstants.billPrintPreview,
          name: RouteConstants.billPrintPreviewRouteName,
          builder: (context, state) {
            final billId = state.pathParameters['id']!;
            return BillPrintPreviewPage(billId: billId);
          },
        ),
        GoRoute(
          path: RouteConstants.production,
          name: RouteConstants.productionRouteName,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: RouteConstants.administration,
          name: RouteConstants.administrationRouteName,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: RouteConstants.staffManagement,
          name: RouteConstants.staffManagementRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => StaffProvider(), child: const StaffManagementPage()),
        ),
        GoRoute(
          path: RouteConstants.auditModelLogs,
          name: RouteConstants.auditModelLogsRouteName,
          builder: (context, state) => const AuditModelLogsPage(),
        ),
        GoRoute(
          path: RouteConstants.auditApiLogs,
          name: RouteConstants.auditApiLogsRouteName,
          builder: (context, state) => const ApiLogsPage(),
        ),
        GoRoute(path: RouteConstants.vendors, name: RouteConstants.vendorsRouteName, builder: (context, state) => const MainLayout()),
        GoRoute(
          path: RouteConstants.vendorDetail,
          name: RouteConstants.vendorDetailRouteName,
          builder: (context, state) {
            final vendorId = state.pathParameters['id']!;
            return VendorDetailPage(vendorId: vendorId);
          },
        ),

        GoRoute(
          path: RouteConstants.createCard,
          name: RouteConstants.createCardRouteName,
          builder: (context, state) {
            final createCardProvider = state.extra as CreateCardProvider?;
            return CreateCardPage(createCardProvider: createCardProvider);
          },
        ),
        GoRoute(path: RouteConstants.similarCards, builder: (context, state) => const SimilarCardsPage()),
        GoRoute(
          path: RouteConstants.bluetoothPrint,
          name: RouteConstants.bluetoothPrintRouteName,
          builder: (context, state) {
            final barcodeData = state.uri.queryParameters['barcode'] ?? '';
            print('BluetoothPrintPage - barcodeData: "$barcodeData"');
            print('BluetoothPrintPage - all query params: ${state.uri.queryParameters}');

            if (barcodeData.isEmpty) {
              // Redirect to dashboard if no barcode is provided
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                  leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.dashboard)),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('No barcode provided', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Redirecting to dashboard...'),
                    ],
                  ),
                ),
              );
            }

            return BluetoothPrintPage(barcodeData: barcodeData);
          },
        ),
        GoRoute(
          path: RouteConstants.cardDetail,
          name: RouteConstants.cardDetailRouteName,
          builder: (context, state) {
            final cardId = state.pathParameters['id']!;
            final cardProvider = state.extra as CardDetailProvider?;
            return CardDetailPage(cardId: cardId, cardProvider: cardProvider);
          },
        ),
        GoRoute(
          path: RouteConstants.customerSearch,
          name: RouteConstants.customerSearchRouteName,
          builder: (context, state) => const CreateOrderCustomerSearchPage(),
        ),
        GoRoute(
          path: RouteConstants.orderItems,
          name: RouteConstants.orderItemsRouteName,
          builder: (context, state) => const CreateOrderPage(),
        ),
        GoRoute(
          path: RouteConstants.orderReview,
          name: RouteConstants.orderReviewRouteName,
          builder: (context, state) => const CreateOrderReviewPage(),
        ),
        GoRoute(
          path: RouteConstants.orderDetail,
          name: RouteConstants.orderDetailRouteName,
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            final orderProvider = state.extra as OrderDetailProvider?;
            return OrderDetailPage(orderId: orderId, orderProvider: orderProvider);
          },
        ),
        GoRoute(
          path: RouteConstants.editOrder,
          name: RouteConstants.editOrderRouteName,
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            final orderProvider = state.extra as OrderDetailProvider?;
            return EditOrderPage(orderId: orderId, orderProvider: orderProvider);
          },
        ),

        // Register route (Admin only)
        GoRoute(
          path: RouteConstants.register,
          name: RouteConstants.registerRouteName,
          builder: (context, state) => const RegisterPage(),
        ),

        // Analytics routes
        GoRoute(
          path: RouteConstants.yearlyProfit,
          name: RouteConstants.yearlyProfitRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => AnalyticsProvider(), child: const YearlyProfitPage()),
        ),
        GoRoute(
          path: RouteConstants.yearlySale,
          name: RouteConstants.yearlySaleRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => AnalyticsProvider(), child: const YearlySalePage()),
        ),
        GoRoute(
          path: RouteConstants.lowStockCards,
          name: RouteConstants.lowStockCardsRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => AnalyticsProvider(), child: const LowStockCardsPage()),
        ),
        GoRoute(
          path: RouteConstants.outOfStockCards,
          name: RouteConstants.outOfStockCardsRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => AnalyticsProvider(), child: const OutOfStockCardsPage()),
        ),
        GoRoute(
          path: RouteConstants.todaysOrders,
          name: RouteConstants.todaysOrdersRouteName,
          builder: (context, state) => ChangeNotifierProvider(create: (_) => AnalyticsProvider(), child: const TodaysOrdersPage()),
        ),
      ],
    );

    // Set the router in the navigation service
    NavigationService.setRouter(router);
  }
}
