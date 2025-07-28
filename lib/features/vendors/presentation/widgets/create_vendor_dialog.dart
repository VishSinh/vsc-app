import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

class CreateVendorDialog extends StatefulWidget {
  const CreateVendorDialog({super.key});

  @override
  State<CreateVendorDialog> createState() => _CreateVendorDialogState();
}

class _CreateVendorDialogState extends State<CreateVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateVendor() async {
    if (!_formKey.currentState!.validate()) return;

    final vendorProvider = context.read<VendorProvider>();

    final success = await vendorProvider.createVendor(name: _nameController.text.trim(), phone: _phoneController.text.trim());

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vendorProvider.successMessage ?? AppConstants.vendorCreatedMessage), backgroundColor: AppConfig.successColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vendor'),
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
            const SizedBox(height: AppConfig.defaultPadding),
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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        Consumer<VendorProvider>(
          builder: (context, vendorProvider, child) {
            return ActionButton(label: 'Create', icon: Icons.add, onPressed: vendorProvider.isLoading ? null : _handleCreateVendor, isLoading: vendorProvider.isLoading);
          },
        ),
      ],
    );
  }
}
