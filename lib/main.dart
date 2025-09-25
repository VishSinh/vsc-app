import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

import 'package:vsc_app/core/constants/app_router.dart';
import 'package:vsc_app/core/constants/app_theme.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/dashboard_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

import 'package:vsc_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/core/providers/navigation_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';

/// Configure full screen mode for tablets (immersive experience like games)
Future<void> _configureFullScreen() async {
  // Check if we're on a tablet by examining screen dimensions
  // We'll use the same breakpoint as the app's responsive utilities
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final size = view.physicalSize / view.devicePixelRatio;

  // Use the same tablet breakpoint as defined in responsive_utils.dart (600dp)
  const tabletBreakpoint = 600;
  final isTablet = size.width >= tabletBreakpoint;

  if (isTablet) {
    // Enable immersive sticky mode for tablets (hides status bar and navigation)
    // Users can temporarily reveal system UI by swiping from edges
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // For tablets, prefer landscape orientation for better game-like experience
    // but still allow portrait if needed
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp, // Allow portrait as fallback
    ]);
  } else {
    // For phones, use normal system UI and allow all orientations
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the logger
  AppLogger.initialize(level: Level.ALL);

  // Initialize the app router
  AppRouter.initialize();

  // Configure full screen mode for tablets
  await _configureFullScreen();

  runApp(const VSCApp());
}

class VSCApp extends StatelessWidget {
  const VSCApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (BuildContext context) => PermissionProvider()),
      ChangeNotifierProvider(create: (BuildContext context) => VendorProvider()),
      ChangeNotifierProvider(create: (BuildContext context) => CustomerProvider()),
      ChangeNotifierProvider(create: (BuildContext context) => AuthProvider()),
      ChangeNotifierProvider(create: (BuildContext context) => DashboardProvider()),
      ChangeNotifierProvider(create: (context) => BillProvider()),
      ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ChangeNotifierProvider(create: (context) => OrderListProvider()),
      ChangeNotifierProvider(create: (context) => CardListProvider()),
      ChangeNotifierProvider(create: (context) => OrderCreateProvider()),
    ],
    child: AuthInitializer(child: _buildApp()),
  );

  Widget _buildApp() {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          title: 'Dashboard',
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthInitializer extends StatefulWidget {
  final Widget child;

  const AuthInitializer({super.key, required this.child});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<AuthProvider>().initializeAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
