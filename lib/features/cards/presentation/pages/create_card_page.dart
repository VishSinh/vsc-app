import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/app/app_config.dart';

class CreateCardPage extends StatefulWidget {
  const CreateCardPage({super.key});

  @override
  State<CreateCardPage> createState() => _CreateCardPageState();
}

class _CreateCardPageState extends State<CreateCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _costPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  String? _selectedVendorId;

  @override
  void initState() {
    super.initState();
    // Load vendors when page opens
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Card'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConfig.largePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.largePadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create New Card', style: AppConfig.headlineStyle.copyWith(color: AppConfig.primaryColor)),
                        const SizedBox(height: AppConfig.smallPadding),
                        Text('Add a new card to the inventory system', style: AppConfig.subtitleStyle),
                        const SizedBox(height: AppConfig.largePadding),

                        // Content Layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Use row layout for larger screens (width > 800)
                            if (constraints.maxWidth > 800) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image section on the left
                                  Expanded(flex: 1, child: _buildImageSection(cardProvider)),
                                  const SizedBox(width: AppConfig.largePadding),
                                  // Form section on the right
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        _buildFormFields(),
                                        const SizedBox(height: AppConfig.largePadding),
                                        _buildSubmitButton(cardProvider),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // Use column layout for smaller screens
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Image Upload Section
                                  _buildImageSection(cardProvider),
                                  const SizedBox(height: AppConfig.largePadding),

                                  // Form Fields
                                  _buildFormFields(),
                                  const SizedBox(height: AppConfig.largePadding),

                                  // Submit Button
                                  _buildSubmitButton(cardProvider),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(CardProvider cardProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: AppConfig.primaryColor, size: AppConfig.fontSize3xl),
                const SizedBox(width: AppConfig.smallPadding),
                Text('Card Image', style: AppConfig.titleStyle),
              ],
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            if (cardProvider.selectedImageUrl != null) ...[
              // Display selected image with 4:3 aspect ratio
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final imageWidth = maxWidth;
                  final imageHeight = (imageWidth * 3) / 4; // 4:3 aspect ratio

                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cardProvider.selectedImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, color: Colors.red, size: 48),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConfig.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ButtonUtils.accentButton(onPressed: () => _showImagePickerDialog(cardProvider), label: 'Change Image', icon: Icons.edit),
                  ),
                  const SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: ButtonUtils.dangerButton(onPressed: cardProvider.clearImage, label: 'Remove', icon: Icons.delete),
                  ),
                ],
              ),
            ] else ...[
              // Upload image placeholder with 4:3 aspect ratio
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final imageWidth = maxWidth;
                  final imageHeight = (imageWidth * 3) / 4; // 4:3 aspect ratio

                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: InkWell(
                      onTap: () => _showImagePickerDialog(cardProvider),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          Text('Tap to upload image', style: AppConfig.bodyStyle.copyWith(color: AppConfig.textColorMuted)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: AppConfig.primaryColor, size: AppConfig.fontSize3xl),
                const SizedBox(width: AppConfig.smallPadding),
                Text('Card Details', style: AppConfig.titleStyle),
              ],
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Cost Price
            TextFormField(
              controller: _costPriceController,
              decoration: InputDecoration(
                labelText: 'Cost Price',
                hintText: 'Enter cost price',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cost price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Sell Price
            TextFormField(
              controller: _sellPriceController,
              decoration: InputDecoration(
                labelText: 'Sell Price',
                hintText: 'Enter sell price',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.sell),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sell price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Max Discount
            TextFormField(
              controller: _maxDiscountController,
              decoration: InputDecoration(
                labelText: 'Max Discount (%)',
                hintText: 'Enter max discount percentage',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.discount),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter max discount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final discount = double.parse(value);
                if (discount < 0 || discount > 100) {
                  return 'Discount must be between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Vendor Dropdown
            Consumer<VendorProvider>(
              builder: (context, vendorProvider, child) {
                if (vendorProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vendorProvider.vendors.isEmpty) {
                  return Text('No vendors available', style: AppConfig.captionStyle);
                }

                return DropdownButtonFormField<String>(
                  value: _selectedVendorId,
                  decoration: InputDecoration(
                    labelText: 'Select Vendor',
                    hintText: 'Choose a vendor',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.people),
                    labelStyle: AppConfig.bodyStyle,
                    hintStyle: AppConfig.captionStyle,
                  ),
                  items: vendorProvider.vendors.map((vendor) {
                    return DropdownMenuItem<String>(
                      value: vendor.id,
                      child: Text(vendor.name, style: AppConfig.bodyStyle),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVendorId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vendor';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(CardProvider cardProvider) {
    return ButtonUtils.fullWidthSuccessButton(
      onPressed: cardProvider.isLoading ? null : _submitForm,
      label: cardProvider.isLoading ? 'Creating...' : 'Create Card',
      icon: Icons.add,
      isLoading: cardProvider.isLoading,
    );
  }

  void _showImagePickerDialog(CardProvider cardProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _uploadDummyImage(cardProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _uploadDummyImage(cardProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDummyImage(CardProvider cardProvider) {
    // Simulate image upload
    cardProvider.uploadImage('dummy_image_file');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final cardProvider = context.read<CardProvider>();

      cardProvider.createCard(
        costPrice: double.parse(_costPriceController.text),
        sellPrice: double.parse(_sellPriceController.text),
        quantity: int.parse(_quantityController.text),
        maxDiscount: double.parse(_maxDiscountController.text),
        vendorId: _selectedVendorId!,
        context: context,
      );
    }
  }
}
