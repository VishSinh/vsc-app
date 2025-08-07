import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';

import 'package:vsc_app/features/cards/presentation/providers/create_card_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

/// Form widget for entering card details
class CardEntryForm extends StatefulWidget {
  final VoidCallback? onSubmit;

  const CardEntryForm({super.key, this.onSubmit});

  @override
  State<CardEntryForm> createState() => _CardEntryFormState();
}

class _CardEntryFormState extends State<CardEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _costPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _maxDiscountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load vendors when form opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().loadVendors();
    });
  }

  @override
  void dispose() {
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CreateCardProvider, VendorProvider>(
      builder: (context, cardProvider, vendorProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Card Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: context.responsiveSpacing),

              // Cost Price
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  errorText: cardProvider.formModel.costPriceError,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateFormField('costPrice', value),
                validator: (value) => cardProvider.validateField('costPrice', value ?? ''),
              ),
              SizedBox(height: context.responsiveSpacing),

              // Sell Price
              TextFormField(
                controller: _sellPriceController,
                decoration: InputDecoration(
                  labelText: 'Sell Price',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  errorText: cardProvider.formModel.sellPriceError,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateFormField('sellPrice', value),
                validator: (value) => cardProvider.validateField('sellPrice', value ?? ''),
              ),
              SizedBox(height: context.responsiveSpacing),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                  errorText: cardProvider.formModel.quantityError,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateFormField('quantity', value),
                validator: (value) => cardProvider.validateField('quantity', value ?? ''),
              ),
              SizedBox(height: context.responsiveSpacing),

              // Max Discount
              TextFormField(
                controller: _maxDiscountController,
                decoration: InputDecoration(
                  labelText: 'Max Discount (%)',
                  prefixIcon: Icon(Icons.discount),
                  border: OutlineInputBorder(),
                  errorText: cardProvider.formModel.maxDiscountError,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateFormField('maxDiscount', value),
                validator: (value) => cardProvider.validateField('maxDiscount', value ?? ''),
              ),
              SizedBox(height: context.responsiveSpacing),

              // Vendor Selection
              DropdownButtonFormField<String>(
                value: cardProvider.formModel.vendorId.isEmpty ? null : cardProvider.formModel.vendorId,
                decoration: InputDecoration(
                  labelText: 'Vendor',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                  errorText: cardProvider.formModel.vendorIdError,
                ),
                items: vendorProvider.vendors.map((vendor) {
                  return DropdownMenuItem<String>(value: vendor.id, child: Text(vendor.name));
                }).toList(),
                onChanged: (value) => _updateFormField('vendorId', value ?? ''),
                validator: (value) => cardProvider.validateField('vendorId', value ?? ''),
              ),
              SizedBox(height: context.responsiveSpacing * 2),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ButtonUtils.primaryButton(
                  onPressed: cardProvider.isFormValid && !cardProvider.isLoading ? () => _handleSubmit(cardProvider) : null,
                  label: 'Create Card',
                  icon: Icons.add,
                  isLoading: cardProvider.isLoading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Update form field in provider
  void _updateFormField(String fieldName, String value) {
    final cardProvider = context.read<CreateCardProvider>();

    switch (fieldName) {
      case 'costPrice':
        cardProvider.updateFormField(costPrice: value);
        break;
      case 'sellPrice':
        cardProvider.updateFormField(sellPrice: value);
        break;
      case 'quantity':
        cardProvider.updateFormField(quantity: value);
        break;
      case 'maxDiscount':
        cardProvider.updateFormField(maxDiscount: value);
        break;
      case 'vendorId':
        cardProvider.updateFormField(vendorId: value);
        break;
    }
  }

  /// Handle form submission
  void _handleSubmit(CreateCardProvider cardProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      await cardProvider.createCard();
      if (widget.onSubmit != null) {
        widget.onSubmit!();
      }
    }
  }
}
