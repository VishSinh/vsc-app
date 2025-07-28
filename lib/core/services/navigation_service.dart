import 'package:go_router/go_router.dart';

class NavigationService {
  static GoRouter? _router;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  static void navigateToLogin() {
    _router?.go('/login');
  }

  static void navigateToDashboard() {
    _router?.go('/dashboard');
  }
}
