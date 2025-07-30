import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';

class CustomerSearchPage extends StatefulWidget {
  const CustomerSearchPage({super.key});

  @override
  State<CustomerSearchPage> createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isCreatingCustomer = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customerProvider = context.read<CustomerProvider>();
    final orderProvider = context.read<OrderProvider>();

    final customer = await customerProvider.searchCustomerByPhone(_phoneController.text.trim());

    if (mounted) {
      if (customer != null) {
        print('🔍 CustomerSearchPage: Customer found: ${customer.name}');
        orderProvider.setSelectedCustomer(customer);
        print('🔍 CustomerSearchPage: Customer set in OrderProvider, navigating to order items');
        SnackbarUtils.showSuccess(context, UITextConstants.customerFoundSuccess);
        context.go(RouteConstants.orderItems);
      } else {
        // Customer not found - show actual API error and suggest creating
        print('🔍 CustomerSearchPage: Customer not found, showing API error');
        final apiErrorMessage = customerProvider.errorMessage ?? UITextConstants.customerNotFoundWithSuggestion;
        SnackbarUtils.showError(context, apiErrorMessage);
        // Clear the provider error since we've handled it specifically
        customerProvider.setError(null);
      }
    }
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customerProvider = context.read<CustomerProvider>();
    final orderProvider = context.read<OrderProvider>();

    final success = await customerProvider.createCustomer(name: _nameController.text.trim(), phone: _phoneController.text.trim());

    if (mounted) {
      if (success) {
        final customer = customerProvider.selectedCustomer;
        if (customer != null) {
          orderProvider.setSelectedCustomer(customer);
          SnackbarUtils.showSuccess(context, UITextConstants.customerCreatedSuccessfully);
          context.go(RouteConstants.orderItems);
        } else {
          SnackbarUtils.showError(context, UITextConstants.customerRetrieveFailed);
        }
      } else {
        // Show error from provider
        final errorMessage = customerProvider.errorMessage ?? UITextConstants.customerCreateFailed;
        SnackbarUtils.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.customerSearchTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.orders)),
      ),
      body: Consumer2<CustomerProvider, OrderProvider>(
        builder: (context, customerProvider, orderProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < AppConfig.mobileBreakpoint) {
                return _buildMobileLayout(customerProvider);
              } else {
                return _buildDesktopLayout(customerProvider);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(CustomerProvider customerProvider) {
    return SingleChildScrollView(padding: EdgeInsets.all(AppConfig.defaultPadding), child: _buildUnifiedForm(customerProvider));
  }

  Widget _buildDesktopLayout(CustomerProvider customerProvider) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(padding: EdgeInsets.all(AppConfig.largePadding), child: _buildUnifiedForm(customerProvider)),
      ),
    );
  }

  Widget _buildUnifiedForm(CustomerProvider customerProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isCreatingCustomer ? 'Create Customer' : 'Search Customer', style: ResponsiveText.getTitle(context)),
              SizedBox(height: AppConfig.defaultPadding),

              // Phone field (always visible)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: UITextConstants.customerPhone,
                  hintText: UITextConstants.customerPhoneHint,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UITextConstants.pleaseEnterCustomerPhone;
                  }
                  return null;
                },
              ),

              // Name field (only visible when creating)
              if (_isCreatingCustomer) ...[
                SizedBox(height: AppConfig.defaultPadding),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: UITextConstants.customerName,
                    hintText: UITextConstants.customerNameHint,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return UITextConstants.pleaseEnterCustomerName;
                    }
                    return null;
                  },
                ),
              ],

              SizedBox(height: AppConfig.defaultPadding),

              // Action buttons
              if (context.isMobile) ...[
                // Mobile: Stacked buttons centered with full width
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _isCreatingCustomer
                            ? ButtonUtils.primaryButton(
                                onPressed: customerProvider.isLoading ? null : _createCustomer,
                                label: UITextConstants.createCustomer,
                                icon: Icons.person_add,
                              )
                            : ButtonUtils.primaryButton(
                                onPressed: customerProvider.isLoading ? null : _searchCustomer,
                                label: UITextConstants.searchCustomer,
                                icon: Icons.search,
                              ),
                      ),
                      SizedBox(height: AppConfig.defaultPadding),
                      SizedBox(
                        width: double.infinity,
                        child: ButtonUtils.secondaryButton(
                          onPressed: () {
                            setState(() {
                              _isCreatingCustomer = !_isCreatingCustomer;
                              if (!_isCreatingCustomer) {
                                // Reset form when switching back to search
                                _nameController.clear();
                                _formKey.currentState?.reset();
                              }
                            });
                          },
                          label: _isCreatingCustomer ? UITextConstants.cancel : UITextConstants.createCustomer,
                          icon: _isCreatingCustomer ? Icons.cancel : Icons.add,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Desktop: Side-by-side buttons with full width
                Row(
                  children: [
                    Expanded(
                      child: _isCreatingCustomer
                          ? ButtonUtils.primaryButton(
                              onPressed: customerProvider.isLoading ? null : _createCustomer,
                              label: UITextConstants.createCustomer,
                              icon: Icons.person_add,
                            )
                          : ButtonUtils.primaryButton(
                              onPressed: customerProvider.isLoading ? null : _searchCustomer,
                              label: UITextConstants.searchCustomer,
                              icon: Icons.search,
                            ),
                    ),
                    SizedBox(width: AppConfig.defaultPadding),
                    Expanded(
                      child: ButtonUtils.secondaryButton(
                        onPressed: () {
                          setState(() {
                            _isCreatingCustomer = !_isCreatingCustomer;
                            if (!_isCreatingCustomer) {
                              // Reset form when switching back to search
                              _nameController.clear();
                              _formKey.currentState?.reset();
                            }
                          });
                        },
                        label: _isCreatingCustomer ? UITextConstants.cancel : UITextConstants.createCustomer,
                        icon: _isCreatingCustomer ? Icons.cancel : Icons.add,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
