import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Initialize the login form in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeLoginForm();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // Update the form with current values
    authProvider.updateLoginForm(phone: _phoneController.text.trim(), password: _passwordController.text);

    final success = await authProvider.login();

    if (success && mounted) {
      // Navigate to dashboard
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppConfig.primaryColor.withValues(alpha: 0.1), AppConfig.accentColor.withValues(alpha: 0.1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveUtils.getFormWidth(context)),
              child: Card(
                elevation: AppConfig.elevationHigh,
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo/Title
                        Icon(Icons.inventory, size: AppConfig.iconSizeXXLarge, color: AppConfig.primaryColor),
                        SizedBox(height: AppConfig.defaultPadding),
                        Text(UITextConstants.appName, style: ResponsiveText.getHeadlineStyle(context)),
                        SizedBox(height: AppConfig.smallPadding),
                        Text(UITextConstants.signInTitle, style: ResponsiveText.getSubtitle(context).copyWith(color: AppConfig.grey600)),
                        SizedBox(height: AppConfig.largePadding),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: UITextConstants.phoneNumber,
                            prefixIcon: const Icon(Icons.phone),
                            hintText: UITextConstants.phoneHint,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return UITextConstants.pleaseEnterPhone;
                            }
                            if (value.length < 10) {
                              return UITextConstants.pleaseEnterValidPhone;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Update form in provider as user types
                            context.read<AuthProvider>().updateLoginForm(phone: value);
                          },
                        ),
                        SizedBox(height: AppConfig.defaultPadding),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: UITextConstants.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return UITextConstants.pleaseEnterPassword;
                            }
                            if (value.length < 6) {
                              return UITextConstants.passwordTooShort;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Update form in provider as user types
                            context.read<AuthProvider>().updateLoginForm(password: value);
                          },
                        ),
                        SizedBox(height: AppConfig.largePadding),

                        // Error Message
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.errorMessage != null) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppConfig.smallPadding),
                                margin: EdgeInsets.only(bottom: AppConfig.defaultPadding),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusSmall),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppConfig.largePadding),
                                  backgroundColor: AppConfig.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(UITextConstants.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
