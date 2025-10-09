/// Route Constants - All application routes and route names
class RouteConstants {
  // ================================ ROUTE PATHS ================================
  static const String login = '/login';
  static const String dashboard = '/';
  static const String bills = '/bills';
  static const String billDetail = '/bills/:id';
  static const String billPrintPreview = '/bills/:id/print';
  static const String orders = '/orders';
  static const String newOrder = '/orders/new';
  static const String editOrder = '/orders/:id/edit';
  static const String inventory = '/inventory';
  static const String production = '/production';
  static const String administration = '/administration';
  static const String staffManagement = '/administration/staff';
  static const String auditModelLogs = '/administration/model-logs';
  static const String auditApiLogs = '/administration/api-logs';
  static const String vendors = '/vendors';
  static const String customers = '/customers';
  static const String vendorDetail = '/vendors/:id';
  static const String cardDetail = '/cards/:id';
  static const String createCard = '/cards/create';
  static const String similarCards = '/cards/similar';
  static const String bluetoothPrint = '/cards/bluetooth-print';
  static const String customerSearch = '/orders/new/customer';
  static const String customerDetail = '/customers/:id';
  static const String orderItems = '/orders/new/items';
  static const String orderReview = '/orders/new/review';
  static const String orderDetail = '/orders/:id';
  static const String register = '/register';
  static const String yearlyProfit = '/analytics/yearly-profit';
  static const String yearlySale = '/analytics/yearly-sale';
  static const String lowStockCards = '/analytics/low-stock-cards';
  static const String mediumStockCards = '/analytics/medium-stock-cards';
  static const String outOfStockCards = '/analytics/out-of-stock-cards';
  static const String todaysOrders = '/analytics/todays-orders';
  static const String pendingOrders = '/analytics/pending-orders';
  static const String pendingBills = '/analytics/pending-bills';

  // ================================ ROUTE NAMES ================================
  static const String loginRouteName = 'login';
  static const String dashboardRouteName = 'dashboard';
  static const String billsRouteName = 'bills';
  static const String billDetailRouteName = 'bill-detail';
  static const String billPrintPreviewRouteName = 'bill-print-preview';
  static const String ordersRouteName = 'orders';
  static const String newOrderRouteName = 'new-order';
  static const String editOrderRouteName = 'edit-order';
  static const String inventoryRouteName = 'inventory';
  static const String productionRouteName = 'production';
  static const String administrationRouteName = 'administration';
  static const String staffManagementRouteName = 'staff-management';
  static const String auditModelLogsRouteName = 'audit-model-logs';
  static const String auditApiLogsRouteName = 'audit-api-logs';
  static const String vendorsRouteName = 'vendors';
  static const String customersRouteName = 'customers';
  static const String vendorDetailRouteName = 'vendor-detail';

  static const String cardDetailRouteName = 'card-detail';
  static const String createCardRouteName = 'create-card';
  static const String bluetoothPrintRouteName = 'bluetooth-print';
  static const String customerSearchRouteName = 'customer-search';
  static const String customerDetailRouteName = 'customer-detail';
  static const String orderItemsRouteName = 'order-items';
  static const String orderReviewRouteName = 'order-review';
  static const String orderDetailRouteName = 'order-detail';
  static const String registerRouteName = 'register';
  static const String yearlyProfitRouteName = 'yearly-profit';
  static const String yearlySaleRouteName = 'yearly-sale';
  static const String lowStockCardsRouteName = 'low-stock-cards';
  static const String mediumStockCardsRouteName = 'medium-stock-cards';
  static const String outOfStockCardsRouteName = 'out-of-stock-cards';
  static const String todaysOrdersRouteName = 'todays-orders';
  static const String pendingOrdersRouteName = 'pending-orders';
  static const String pendingBillsRouteName = 'pending-bills';
}
