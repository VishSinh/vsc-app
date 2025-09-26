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
  // Detect based on the shortest side so orientation does not affect tablet detection
  const tabletBreakpoint = 600;
  final isTablet = size.shortestSide >= tabletBreakpoint;

  if (isTablet) {
    // Tablets: immersive and forced landscape
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  } else {
    // Phones: normal system UI and forced portrait
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      // CustomerProvider removed; customer APIs are called from feature-specific providers
      ChangeNotifierProxyProvider<PermissionProvider, AuthProvider>(
        create: (BuildContext context) => AuthProvider(),
        update: (BuildContext context, PermissionProvider permissionProvider, AuthProvider? authProvider) {
          authProvider ??= AuthProvider();
          authProvider.setPermissionProvider(permissionProvider);
          return authProvider;
        },
      ),
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
        return SystemUiRestorer(
          child: MaterialApp.router(
            title: 'Dashboard',
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          ),
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

/// Restores immersive mode on resume/orientation changes so nav bars stay hidden on tablets
class SystemUiRestorer extends StatefulWidget {
  final Widget child;

  const SystemUiRestorer({super.key, required this.child});

  @override
  State<SystemUiRestorer> createState() => _SystemUiRestorerState();
}

class _SystemUiRestorerState extends State<SystemUiRestorer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ensure correct mode after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySystemUiForDevice();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applySystemUiForDevice();
    }
  }

  @override
  void didChangeMetrics() {
    // Called on orientation change or when insets change
    _applySystemUiForDevice();
  }

  Future<void> _applySystemUiForDevice() async {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    const tabletBreakpoint = 600;
    final isTablet = size.shortestSide >= tabletBreakpoint;

    if (isTablet) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
