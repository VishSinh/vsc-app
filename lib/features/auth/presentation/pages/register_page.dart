import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.sales;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole.value,
      context: context,
    );

    if (success && mounted) {
      // Show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.successMessage ?? UITextConstants.registrationSuccessful), backgroundColor: AppConfig.successColor),
      );

      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _selectedRole = UserRole.sales;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UITextConstants.registerTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.administration)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.largePadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConfig.maxWidthMedium),
          child: Card(
            elevation: AppConfig.elevationMedium,
            child: Padding(
              padding: const EdgeInsets.all(AppConfig.largePadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UITextConstants.registerStaffMember,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConfig.smallPadding),
                    Text(UITextConstants.registerSubtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppConfig.grey600)),
                    const SizedBox(height: AppConfig.largePadding),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: UITextConstants.fullName,
                        prefixIcon: const Icon(Icons.person),
                        hintText: UITextConstants.nameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return UITextConstants.pleaseEnterFullName;
                        }
                        if (value.length < 2) {
                          return UITextConstants.nameTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),

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
                    const SizedBox(height: AppConfig.defaultPadding),

                    // Role Selection
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: InputDecoration(labelText: UITextConstants.role, prefixIcon: const Icon(Icons.work)),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role.value));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),

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
                        if (value.length < 8) {
                          return UITextConstants.passwordTooShortRegister;
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                          return UITextConstants.passwordComplexity;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: UITextConstants.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return UITextConstants.pleaseEnterConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return UITextConstants.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConfig.largePadding),

                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.errorMessage != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConfig.smallPadding),
                            margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding),
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

                    // Success Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.successMessage != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConfig.smallPadding),
                            margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding),
                            decoration: BoxDecoration(
                              color: AppConfig.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                              border: Border.all(color: AppConfig.successColor),
                            ),
                            child: Text(authProvider.successMessage!, style: TextStyle(color: AppConfig.successColor)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return ButtonUtils.fullWidthPrimaryButton(
                          onPressed: _handleRegister,
                          label: UITextConstants.registerStaffMember,
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
    );
  }
}
