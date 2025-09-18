/// Route Constants - All application routes and route names
class RouteConstants {
  // ================================ ROUTE PATHS ================================
  static const String login = '/login';
  static const String dashboard = '/';
  static const String bills = '/bills';
  static const String billDetail = '/bills/:id';
  static const String orders = '/orders';
  static const String newOrder = '/orders/new';
  static const String inventory = '/inventory';
  static const String production = '/production';
  static const String administration = '/administration';
  static const String vendors = '/vendors';
  static const String vendorDetail = '/vendors/:id';
  static const String cardDetail = '/cards/:id';
  static const String createCard = '/cards/create';
  static const String similarCards = '/cards/similar';
  static const String bluetoothPrint = '/cards/bluetooth-print';
  static const String customerSearch = '/orders/new/customer';
  static const String orderItems = '/orders/new/items';
  static const String orderReview = '/orders/new/review';
  static const String orderDetail = '/orders/:id';
  static const String register = '/register';
  static const String yearlyProfit = '/analytics/yearly-profit';
  static const String lowStockCards = '/analytics/low-stock-cards';
  static const String outOfStockCards = '/analytics/out-of-stock-cards';

  // ================================ ROUTE NAMES ================================
  static const String loginRouteName = 'login';
  static const String dashboardRouteName = 'dashboard';
  static const String billsRouteName = 'bills';
  static const String billDetailRouteName = 'bill-detail';
  static const String ordersRouteName = 'orders';
  static const String newOrderRouteName = 'new-order';
  static const String inventoryRouteName = 'inventory';
  static const String productionRouteName = 'production';
  static const String administrationRouteName = 'administration';
  static const String vendorsRouteName = 'vendors';
  static const String vendorDetailRouteName = 'vendor-detail';

  static const String cardDetailRouteName = 'card-detail';
  static const String createCardRouteName = 'create-card';
  static const String bluetoothPrintRouteName = 'bluetooth-print';
  static const String customerSearchRouteName = 'customer-search';
  static const String orderItemsRouteName = 'order-items';
  static const String orderReviewRouteName = 'order-review';
  static const String orderDetailRouteName = 'order-detail';
  static const String registerRouteName = 'register';
  static const String yearlyProfitRouteName = 'yearly-profit';
  static const String lowStockCardsRouteName = 'low-stock-cards';
  static const String outOfStockCardsRouteName = 'out-of-stock-cards';

  // ================================ ROUTE GROUPS ================================
  static const List<String> protectedRoutes = [
    dashboard,
    bills,
    orders,
    newOrder,
    inventory,
    production,
    administration,
    vendors,
    vendorDetail,

    cardDetail,
    createCard,
    bluetoothPrint,
    customerSearch,
    orderItems,
    orderReview,
    orderDetail,
    register,
    billDetail,
    yearlyProfit,
    lowStockCards,
    outOfStockCards,
  ];

  static const List<String> publicRoutes = [login];

  static const List<String> adminOnlyRoutes = [register];
}
