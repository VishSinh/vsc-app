import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

class CreateVendorDialog extends StatefulWidget {
  final Vendor? vendor;
  final bool isEditing;

  const CreateVendorDialog({super.key, this.vendor, this.isEditing = false});

  @override
  State<CreateVendorDialog> createState() => _CreateVendorDialogState();
}

class _CreateVendorDialogState extends State<CreateVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.vendor != null) {
      _nameController.text = widget.vendor!.name;
      _phoneController.text = widget.vendor!.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final vendorProvider = context.read<VendorProvider>();

    if (widget.isEditing && widget.vendor != null) {
      // Update existing vendor
      final success = await vendorProvider.updateVendor(
        id: widget.vendor!.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      // Create new vendor
      final success = await vendorProvider.createVendor(name: _nameController.text.trim(), phone: _phoneController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Vendor' : 'Add New Vendor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Vendor Name', prefixIcon: Icon(Icons.business), hintText: 'Enter vendor name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vendor name';
                }
                if (value.length < AppConstants.minNameLength) {
                  return 'Name must be at least ${AppConstants.minNameLength} characters';
                }
                return null;
              },
            ),
            SizedBox(height: AppConfig.defaultPadding),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: 'Enter phone number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length < AppConstants.minPhoneLength) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
        Consumer<VendorProvider>(
          builder: (context, vendorProvider, child) {
            return ActionButton(
              label: widget.isEditing ? 'Update' : UITextConstants.create,
              icon: widget.isEditing ? Icons.edit : Icons.add,
              onPressed: vendorProvider.isLoading ? null : _handleSubmit,
              isLoading: vendorProvider.isLoading,
            );
          },
        ),
      ],
    );
  }
}
