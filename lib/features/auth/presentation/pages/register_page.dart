import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.successMessage ?? 'Registration successful'), backgroundColor: AppConfig.successColor));

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
        title: const Text('Register New Staff'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/administration')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.largePadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppConfig.largePadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Register New Staff Member', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppConfig.smallPadding),
                    Text('Add a new staff member to the system', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: AppConfig.largePadding),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), hintText: 'John Doe'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the full name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '9876543210'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),

                    // Role Selection
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.work)),
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
                        labelText: 'Password',
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
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                          return 'Password must contain uppercase, lowercase, and number';
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
                        labelText: 'Confirm Password',
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
                          return 'Please confirm the password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
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
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleRegister,
                            child: authProvider.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Register Staff Member'),
                          );
                        },
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
}
