import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

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
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(phone: _phoneController.text.trim(), password: _passwordController.text, context: context);

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
            colors: [AppConfig.primaryColor.withOpacity(0.1), AppConfig.accentColor.withOpacity(0.1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConfig.largePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppConfig.maxWidthSmall),
              child: Card(
                elevation: AppConfig.elevationHigh,
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.largePadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo/Title
                        Icon(Icons.inventory, size: AppConfig.iconSizeXXLarge, color: AppConfig.primaryColor),
                        SizedBox(height: AppConfig.defaultPadding),
                        Text(AppConfig.appName, style: ResponsiveText.getHeadline(context).copyWith(color: AppConfig.primaryColor)),
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
                                  color: AppConfig.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                                  border: Border.all(color: AppConfig.errorColor),
                                ),
                                child: Text(authProvider.errorMessage!, style: TextStyle(color: AppConfig.errorColor)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return ButtonUtils.fullWidthPrimaryButton(
                              onPressed: _handleLogin,
                              label: UITextConstants.signIn,
                              isLoading: authProvider.isLoading,
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
