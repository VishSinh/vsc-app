import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/app/app_router.dart';
import 'package:vsc_app/app/app_theme.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

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
        ChangeNotifierProxyProvider<PermissionProvider, AuthProvider>(
          create: (context) => AuthProvider(permissionProvider: context.read<PermissionProvider>()),
          update: (context, permissionProvider, previous) => previous ?? AuthProvider(permissionProvider: permissionProvider),
        ),
      ],
      child: AuthInitializer(
        child: MaterialApp.router(
          title: AppConfig.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
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
