import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';

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
  void initState() {
    super.initState();
    // Initialize the register form in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeRegisterForm();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // Update the form with current values
    authProvider.updateRegisterForm(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      role: _selectedRole.value,
    );

    final success = await authProvider.register();

    if (success && mounted) {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(UITextConstants.registerTitle),
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
    ),
    body: SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ResponsiveUtils.getFormWidth(context)),
        child: Card(
          elevation: AppConfig.elevationMedium,
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(UITextConstants.registerStaffMember, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: AppConfig.smallPadding),
                  Text(UITextConstants.registerSubtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppConfig.grey600)),
                  SizedBox(height: AppConfig.largePadding),

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
                    onChanged: (value) {
                      context.read<AuthProvider>().updateRegisterForm(name: value);
                    },
                  ),
                  SizedBox(height: AppConfig.defaultPadding),

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
                      context.read<AuthProvider>().updateRegisterForm(phone: value);
                    },
                  ),
                  SizedBox(height: AppConfig.defaultPadding),

                  // Role Selection
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(labelText: UITextConstants.role, prefixIcon: const Icon(Icons.work)),
                    items: UserRole.values.map((role) => DropdownMenuItem(value: role, child: Text(role.value))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                        context.read<AuthProvider>().updateRegisterForm(role: value.value);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a role';
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
                    onChanged: (value) {
                      context.read<AuthProvider>().updateRegisterForm(password: value);
                    },
                  ),
                  SizedBox(height: AppConfig.defaultPadding),

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
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      context.read<AuthProvider>().updateRegisterForm(confirmPassword: value);
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

                  // Register Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppConfig.largePadding),
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(UITextConstants.registerStaff, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
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
