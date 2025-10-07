import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_update_form_model.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/enums/card_type.dart';

/// Dialog for editing card details
class EditCardDialog extends StatefulWidget {
  final CardViewModel card;
  final VoidCallback onCardUpdated;
  final CardDetailProvider cardProvider;
  final VendorProvider vendorProvider;

  const EditCardDialog({
    super.key,
    required this.card,
    required this.onCardUpdated,
    required this.cardProvider,
    required this.vendorProvider,
  });

  @override
  State<EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _maxDiscountController;
  late String? _selectedVendorId;
  CardType? _selectedCardType;

  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current card data
    _costPriceController = TextEditingController(text: widget.card.costPrice);
    _sellPriceController = TextEditingController(text: widget.card.sellPrice);
    _quantityController = TextEditingController(text: widget.card.quantity.toString());
    _maxDiscountController = TextEditingController(text: widget.card.maxDiscount);
    _selectedVendorId = widget.card.vendorId;
    _selectedCardType = widget.card.cardType ?? CardTypeExtension.fromApiString(widget.card.cardTypeRaw);
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
    return Dialog(
      child: Container(
        width: context.isDesktop ? 600 : double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(padding: context.responsivePadding, child: _buildForm()),
            ),
            const Divider(height: 1),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: context.responsivePadding,
      child: Row(
        children: [
          Icon(Icons.edit, color: AppConfig.primaryColor, size: 24),
          SizedBox(width: AppConfig.smallPadding),
          Expanded(
            child: Text('Edit Card', style: ResponsiveText.getTitle(context).copyWith(fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          SizedBox(height: context.responsiveSpacing),
          _buildCardTypeDropdown(),
          SizedBox(height: context.responsiveSpacing),
          _buildPriceFields(),
          SizedBox(height: context.responsiveSpacing),
          _buildInventoryFields(),
          SizedBox(height: context.responsiveSpacing),
          _buildVendorDropdown(),
        ],
      ),
    );
  }

  Widget _buildCardTypeDropdown() {
    return DropdownButtonFormField<CardType>(
      value: _selectedCardType,
      decoration: InputDecoration(
        labelText: UITextConstants.cardType,
        hintText: UITextConstants.cardType,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.category),
      ),
      items: CardType.values
          .map(
            (ct) => DropdownMenuItem<CardType>(
              value: ct,
              child: Text(ct.displayText, style: ResponsiveText.getBody(context)),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedCardType = val),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Image (Optional)', style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConfig.smallPadding),
        InkWell(
          onTap: _showImagePickerDialog,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppConfig.grey400),
              borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
              child: _selectedImage != null
                  ? Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => _buildImageErrorPlaceholder(),
                    )
                  : widget.card.image.isNotEmpty
                  ? Stack(
                      children: [
                        Image.network(
                          widget.card.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => _buildImageErrorPlaceholder(),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                            child: Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),
        SizedBox(height: AppConfig.smallPadding),
        Row(
          children: [
            if (_selectedImage != null) ...[
              TextButton.icon(
                onPressed: () => setState(() => _selectedImage = null),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Use Original Image'),
                style: TextButton.styleFrom(foregroundColor: AppConfig.primaryColor),
              ),
              SizedBox(width: AppConfig.smallPadding),
            ],
            TextButton.icon(
              onPressed: _showImagePickerDialog,
              icon: const Icon(Icons.photo_camera, size: 16),
              label: Text(_selectedImage != null ? 'Change Again' : 'Change Image'),
              style: TextButton.styleFrom(foregroundColor: AppConfig.secondaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 32, color: AppConfig.textColorSecondary),
        SizedBox(height: AppConfig.smallPadding),
        Text('Tap to add image', style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.textColorSecondary)),
      ],
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      color: AppConfig.grey300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: AppConfig.grey600, size: 32),
          SizedBox(height: AppConfig.smallPadding),
          Text('Image could not be loaded', style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.grey600)),
        ],
      ),
    );
  }

  Widget _buildPriceFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: UITextConstants.costPrice,
                  hintText: UITextConstants.costPriceHint,
                  prefixIcon: const Icon(Icons.monetization_on),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _sellPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: UITextConstants.sellPrice,
                  hintText: UITextConstants.sellPriceHint,
                  prefixIcon: const Icon(Icons.sell),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConfig.defaultPadding),
        TextFormField(
          controller: _maxDiscountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: UITextConstants.maxDiscount,
            hintText: UITextConstants.maxDiscountHint,
            prefixIcon: const Icon(Icons.percent),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryFields() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: UITextConstants.quantity,
        hintText: UITextConstants.quantityHint,
        prefixIcon: const Icon(Icons.inventory),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildVendorDropdown() {
    return Consumer<VendorProvider>(
      builder: (context, vendorProvider, child) {
        if (vendorProvider.isLoading) {
          return const Center(child: LoadingWidget());
        }

        if (vendorProvider.vendors.isEmpty) {
          return Text('No vendors available', style: ResponsiveText.getCaption(context));
        }

        return DropdownButtonFormField<String>(
          value: _selectedVendorId,
          decoration: InputDecoration(
            labelText: UITextConstants.selectVendor,
            hintText: UITextConstants.chooseVendorHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.people),
          ),
          items: vendorProvider.vendors.map((vendor) {
            return DropdownMenuItem<String>(
              value: vendor.id,
              child: Text(vendor.name, style: ResponsiveText.getBody(context)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedVendorId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: context.responsivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
          SizedBox(width: AppConfig.defaultPadding),
          ActionButton(
            label: 'Update Card',
            icon: Icons.save,
            onPressed: widget.cardProvider.isLoading ? null : _handleUpdate,
            isLoading: widget.cardProvider.isLoading,
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppConfig.errorColor));
      }
    }
  }

  Future<void> _handleUpdate() async {
    final cardProvider = widget.cardProvider;

    // Check if any field has been changed from original values
    final hasChanges =
        (_costPriceController.text.trim() != widget.card.costPrice) ||
        (_sellPriceController.text.trim() != widget.card.sellPrice) ||
        (_quantityController.text.trim() != widget.card.quantity.toString()) ||
        (_maxDiscountController.text.trim() != widget.card.maxDiscount) ||
        (_selectedVendorId != widget.card.vendorId) ||
        ((_selectedCardType?.toApiString() ?? widget.card.cardTypeRaw) != widget.card.cardTypeRaw) ||
        (_selectedImage != null);

    if (!hasChanges) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text('No changes detected'), backgroundColor: AppConfig.warningColor));
      return;
    }

    // Create form model with only changed values
    final formModel = CardUpdateFormModel(
      costPrice: _costPriceController.text.trim() != widget.card.costPrice
          ? (_costPriceController.text.trim().isNotEmpty ? _costPriceController.text.trim() : null)
          : null,
      sellPrice: _sellPriceController.text.trim() != widget.card.sellPrice
          ? (_sellPriceController.text.trim().isNotEmpty ? _sellPriceController.text.trim() : null)
          : null,
      quantity: _quantityController.text.trim() != widget.card.quantity.toString()
          ? (_quantityController.text.trim().isNotEmpty ? _quantityController.text.trim() : null)
          : null,
      maxDiscount: _maxDiscountController.text.trim() != widget.card.maxDiscount
          ? (_maxDiscountController.text.trim().isNotEmpty ? _maxDiscountController.text.trim() : null)
          : null,
      vendorId: _selectedVendorId != widget.card.vendorId ? _selectedVendorId : null,
      image: _selectedImage,
      cardType: ((_selectedCardType?.toApiString() ?? widget.card.cardTypeRaw) != widget.card.cardTypeRaw) ? _selectedCardType : null,
    );

    final success = await cardProvider.updateCard(widget.card.id, formModel);

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onCardUpdated();
    }
  }
}
