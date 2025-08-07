import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

import 'package:vsc_app/app/app_router.dart';
import 'package:vsc_app/app/app_theme.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

import 'package:vsc_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/core/providers/navigation_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';

void main() {
  // Initialize the logger
  AppLogger.initialize(level: Level.ALL);

  // Initialize the app router
  AppRouter.initialize();
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
