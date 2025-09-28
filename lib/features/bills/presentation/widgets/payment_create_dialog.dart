import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/enums/payment_mode.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_form_model.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/services/payment_validators.dart';

class PaymentCreateDialog extends StatefulWidget {
  final String billId;
  final double remainingAmount;

  const PaymentCreateDialog({super.key, required this.billId, required this.remainingAmount});

  @override
  State<PaymentCreateDialog> createState() => _PaymentCreateDialogState();
}

class _PaymentCreateDialogState extends State<PaymentCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionRefController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Amount field is left empty to avoid pre-populating and potential mistakes
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: context.isDesktop ? 500 : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Header
            Padding(
              padding: EdgeInsets.only(
                left: context.responsivePadding.left,
                right: context.responsivePadding.right,
                top: context.responsivePadding.top,
              ),
              child: _buildHeader(),
            ),
            // Scrollable Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.responsivePadding.left),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.responsiveSpacing),
                    _buildForm(),
                    SizedBox(height: context.responsiveSpacing),
                  ],
                ),
              ),
            ),
            // Fixed Actions
            Padding(
              padding: EdgeInsets.only(
                left: context.responsivePadding.left,
                right: context.responsivePadding.right,
                bottom: context.responsivePadding.bottom,
              ),
              child: _buildActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.payment, color: AppConfig.primaryColor, size: context.isMobile ? 20 : 24),
        SizedBox(width: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
        Expanded(
          child: Text(
            'Create Payment',
            style: ResponsiveText.getTitle(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: context.isMobile ? 20 : 24),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountField(),
          SizedBox(height: AppConfig.smallPadding),
          _buildPaymentModeField(),
          SizedBox(height: AppConfig.smallPadding),
          _buildTransactionRefField(),
          SizedBox(height: AppConfig.smallPadding),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (₹)',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
          validator: (value) {
            final result = PaymentValidators.validateAmount(value ?? '', maxAmount: widget.remainingAmount);
            return result.isValid ? null : result.firstMessage;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentModeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Mode',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        DropdownButtonFormField<PaymentMode>(
          value: _selectedPaymentMode,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.payment),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
          items: PaymentMode.values.map((mode) {
            return DropdownMenuItem(value: mode, child: Text(mode.name.toUpperCase()));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentMode = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTransactionRefField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Reference (Optional)',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        TextFormField(
          controller: _transactionRefController,
          decoration: InputDecoration(
            hintText: 'Enter transaction reference',
            prefixIcon: const Icon(Icons.receipt),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        TextFormField(
          controller: _notesController,
          maxLines: context.isMobile ? 2 : 3,
          minLines: context.isMobile ? 1 : 2,
          decoration: InputDecoration(
            hintText: 'Enter payment notes',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return context.isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _createPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Payment'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: Text(UITextConstants.cancel),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
              SizedBox(width: AppConfig.smallPadding),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPayment,
                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: Colors.white),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Payment'),
              ),
            ],
          );
  }

  Future<void> _createPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final paymentForm = PaymentFormModel(
        billId: widget.billId,
        amount: amount,
        paymentMode: _selectedPaymentMode,
        transactionRef: _transactionRefController.text.trim(),
        notes: _notesController.text.trim(),
      );

      final billProvider = context.read<BillProvider>();
      await billProvider.createPayment(paymentFormModel: paymentForm);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
