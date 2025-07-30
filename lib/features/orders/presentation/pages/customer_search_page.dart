import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
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

    if (customer != null && mounted) {
      orderProvider.setSelectedCustomer(customer);
      context.go(RouteConstants.orderItems);
    }
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customerProvider = context.read<CustomerProvider>();
    final orderProvider = context.read<OrderProvider>();

    final success = await customerProvider.createCustomer(name: _nameController.text.trim(), phone: _phoneController.text.trim());

    if (success && mounted) {
      final customer = customerProvider.selectedCustomer;
      if (customer != null) {
        orderProvider.setSelectedCustomer(customer);
        context.go(RouteConstants.orderItems);
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppConfig.largePadding),
          _buildSearchForm(customerProvider),
          if (_isCreatingCustomer) ...[SizedBox(height: AppConfig.largePadding), _buildCreateForm(customerProvider)],
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(CustomerProvider customerProvider) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConfig.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: AppConfig.largePadding),
                _buildSearchForm(customerProvider),
              ],
            ),
          ),
        ),
        if (_isCreatingCustomer)
          Expanded(
            flex: 1,
            child: SingleChildScrollView(padding: EdgeInsets.all(AppConfig.largePadding), child: _buildCreateForm(customerProvider)),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(UITextConstants.customerSearchTitle, style: ResponsiveText.getHeadline(context).copyWith(color: AppConfig.primaryColor)),
        SizedBox(height: AppConfig.smallPadding),
        Text(UITextConstants.customerSearchSubtitle, style: AppConfig.subtitleStyle),
      ],
    );
  }

  Widget _buildSearchForm(CustomerProvider customerProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search Customer', style: ResponsiveText.getTitle(context)),
              SizedBox(height: AppConfig.defaultPadding),
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
              SizedBox(height: AppConfig.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ButtonUtils.primaryButton(
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
                        });
                      },
                      label: _isCreatingCustomer ? 'Cancel' : UITextConstants.createCustomer,
                      icon: _isCreatingCustomer ? Icons.cancel : Icons.add,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm(CustomerProvider customerProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Customer', style: ResponsiveText.getTitle(context)),
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
            SizedBox(height: AppConfig.defaultPadding),
            SizedBox(
              width: double.infinity,
              child: ButtonUtils.primaryButton(
                onPressed: customerProvider.isLoading ? null : _createCustomer,
                label: UITextConstants.createCustomer,
                icon: Icons.person_add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
