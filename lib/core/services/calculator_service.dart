import 'package:vsc_app/core/constants/app_router.dart';
import 'package:vsc_app/core/widgets/tools_sheet.dart';

class CalculatorService {
  static bool _isOpen = false;

  static bool get isOpen => _isOpen;

  static Future<String?> toggle() async {
    final navigatorContext = AppRouter.rootNavigatorKey.currentContext;
    if (navigatorContext == null) return null;

    if (_isOpen) {
      _isOpen = false;
      AppRouter.rootNavigatorKey.currentState?.pop();
      return null;
    }

    _isOpen = true;
    try {
      final result = await ToolsSheet.show(navigatorContext);
      return result;
    } finally {
      _isOpen = false;
    }
  }
}
