import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/enums/bill_adjustment_type.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_adjustment_form_model.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';

class BillAdjustmentCreateDialog extends StatefulWidget {
  final String billId;
  final double remainingAmount;

  const BillAdjustmentCreateDialog({super.key, required this.billId, required this.remainingAmount});

  @override
  State<BillAdjustmentCreateDialog> createState() => _BillAdjustmentCreateDialogState();
}

class _BillAdjustmentCreateDialogState extends State<BillAdjustmentCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  BillAdjustmentType _selectedType = BillAdjustmentType.negotiation;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
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
            Padding(
              padding: EdgeInsets.only(
                left: context.responsivePadding.left,
                right: context.responsivePadding.right,
                top: context.responsivePadding.top,
              ),
              child: _buildHeader(),
            ),
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
        Icon(Icons.tune, color: AppConfig.primaryColor, size: context.isMobile ? 20 : 24),
        SizedBox(width: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
        Expanded(
          child: Text(
            'Make Bill Adjustment',
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
          _buildTypeField(),
          SizedBox(height: AppConfig.smallPadding),
          _buildReasonField(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjustment Amount (₹)',
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
            final text = (value ?? '').trim();
            if (text.isEmpty) return 'Amount is required';
            final parsed = double.tryParse(text);
            if (parsed == null) return 'Please enter a valid number';
            if (parsed <= 0) return 'Amount must be greater than 0';
            if (parsed > widget.remainingAmount) return 'Amount cannot exceed pending (₹${widget.remainingAmount.toStringAsFixed(2)})';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjustment Type',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        DropdownButtonFormField<BillAdjustmentType>(
          value: _selectedType,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
          items: BillAdjustmentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayText))).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
        ),
        SizedBox(height: AppConfig.smallPadding),
        TextFormField(
          controller: _reasonController,
          maxLines: context.isMobile ? 2 : 3,
          minLines: context.isMobile ? 1 : 2,
          decoration: InputDecoration(
            hintText: 'Enter reason for adjustment',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
          ),
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return 'Reason is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isMobile = context.isMobile;
    final submitButton = ElevatedButton(
      onPressed: _isLoading ? null : _createAdjustment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(isMobile ? double.infinity : 120, 48),
      ),
      child: _isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Create Adjustment'),
    );

    final cancelButton = TextButton(
      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(minimumSize: Size(isMobile ? double.infinity : 80, 48)),
      child: Text(UITextConstants.cancel),
    );

    return isMobile
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [submitButton, const SizedBox(height: 8), cancelButton])
        : Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancelButton, const SizedBox(width: 8), submitButton]);
  }

  Future<void> _createAdjustment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final form = BillAdjustmentFormModel(
        billId: widget.billId,
        amount: amount,
        adjustmentType: _selectedType,
        reason: _reasonController.text.trim(),
      );

      final provider = context.read<BillProvider>();
      await provider.createBillAdjustment(formModel: form);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create bill adjustment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
