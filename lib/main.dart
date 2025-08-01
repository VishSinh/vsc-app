import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/app/app_router.dart';
import 'package:vsc_app/app/app_theme.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';

void main() {
  // Initialize the app router
  AppRouter.initialize();
  runApp(const VSCApp());
}

class VSCApp extends StatelessWidget {
  const VSCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PermissionProvider()),
        ChangeNotifierProvider(create: (context) => VendorProvider()),
        ChangeNotifierProvider(create: (context) => CardProvider()),
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProxyProvider<PermissionProvider, AuthProvider>(
          create: (context) => AuthProvider(permissionProvider: context.read<PermissionProvider>()),
          update: (context, permissionProvider, previous) => previous ?? AuthProvider(permissionProvider: permissionProvider),
        ),
      ],
      child: AuthInitializer(child: _buildApp()),
    );
  }

  Widget _buildApp() {
    // Toggle this to enable/disable ScreenUtil
    const bool useScreenUtil = true; // Set to true to enable ScreenUtil

    if (useScreenUtil) {
      return ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
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
    } else {
      return MaterialApp.router(
        title: 'Dashboard',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      );
    }
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
