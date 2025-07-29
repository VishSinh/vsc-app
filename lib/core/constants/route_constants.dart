/// Route Constants - All application routes and route names
class RouteConstants {
  // ================================ ROUTE PATHS ================================
  static const String login = '/login';
  static const String dashboard = '/';
  static const String orders = '/orders';
  static const String newOrder = '/orders/new';
  static const String inventory = '/inventory';
  static const String production = '/production';
  static const String administration = '/administration';
  static const String vendors = '/vendors';
  static const String vendorDetail = '/vendors/:id';
  static const String cards = '/cards';
  static const String cardDetail = '/cards/:id';
  static const String createCard = '/cards/create';
  static const String similarCards = '/cards/similar';
  static const String register = '/register';

  // ================================ ROUTE NAMES ================================
  static const String loginRouteName = 'login';
  static const String dashboardRouteName = 'dashboard';
  static const String ordersRouteName = 'orders';
  static const String newOrderRouteName = 'new-order';
  static const String inventoryRouteName = 'inventory';
  static const String productionRouteName = 'production';
  static const String administrationRouteName = 'administration';
  static const String vendorsRouteName = 'vendors';
  static const String vendorDetailRouteName = 'vendor-detail';
  static const String cardsRouteName = 'cards';
  static const String cardDetailRouteName = 'card-detail';
  static const String createCardRouteName = 'create-card';
  static const String registerRouteName = 'register';

  // ================================ ROUTE GROUPS ================================
  static const List<String> protectedRoutes = [
    dashboard,
    orders,
    newOrder,
    inventory,
    production,
    administration,
    vendors,
    vendorDetail,
    cards,
    cardDetail,
    createCard,
    register,
  ];

  static const List<String> publicRoutes = [login];

  static const List<String> adminOnlyRoutes = [register];
}
