import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

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
        title: Text(UITextConstants.createCard),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.inventory)),
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          return SingleChildScrollView(
            padding: context.responsivePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: context.responsivePadding,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          _buildHeaderSection(),
                          SizedBox(height: context.responsiveSpacing),

                          // Content Layout
                          if (context.isDesktop) ...[
                            // Desktop: Side-by-side layout
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: _buildImageSection(cardProvider)),
                                SizedBox(width: context.responsiveSpacing),
                                Expanded(flex: 1, child: _buildFormSection(cardProvider)),
                              ],
                            ),
                          ] else ...[
                            // Mobile/Tablet: Stacked layout
                            _buildImageSection(cardProvider),
                            SizedBox(height: context.isMobile ? AppConfig.defaultPadding : context.responsiveSpacing),
                            _buildFormSection(cardProvider),
                          ],
                        ],
                      ),
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(UITextConstants.createCardTitle, style: ResponsiveText.getHeadline(context).copyWith(color: AppConfig.primaryColor)),
        SizedBox(height: AppConfig.smallPadding),
        Text(UITextConstants.createCardSubtitle, style: ResponsiveText.getSubtitle(context)),
      ],
    );
  }

  Widget _buildFormSection(CardProvider cardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFormFields(),
        SizedBox(height: context.isMobile ? AppConfig.defaultPadding : AppConfig.largePadding),
        _buildSubmitButton(cardProvider),
      ],
    );
  }

  Widget _buildImageSection(CardProvider cardProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: AppConfig.primaryColor, size: AppConfig.iconSizeLarge),
                SizedBox(width: AppConfig.smallPadding),
                Text(UITextConstants.cardImage, style: ResponsiveText.getTitle(context)),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),

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
                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                      border: Border.all(color: AppConfig.grey300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cardProvider.selectedImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppConfig.grey300,
                            child: const Icon(Icons.error, color: AppConfig.red, size: AppConfig.iconSizeXLarge),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppConfig.defaultPadding),
              // Responsive button layout
              if (context.isMobile) ...[
                // Mobile: Full-width buttons matching image width
                SizedBox(
                  width: double.infinity,
                  child: ButtonUtils.accentButton(
                    onPressed: () => _showImagePickerDialog(cardProvider),
                    label: UITextConstants.changeImage,
                    icon: Icons.edit,
                  ),
                ),
                SizedBox(height: AppConfig.smallPadding),
                SizedBox(
                  width: double.infinity,
                  child: ButtonUtils.dangerButton(onPressed: cardProvider.clearImage, label: UITextConstants.remove, icon: Icons.delete),
                ),
                SizedBox(height: AppConfig.smallPadding),
                SizedBox(
                  width: double.infinity,
                  child: ButtonUtils.secondaryButton(
                    onPressed: () => _checkSimilarCards(cardProvider),
                    label: 'Check Similar Cards',
                    icon: Icons.search,
                  ),
                ),
              ] else ...[
                // Desktop/Tablet: Side-by-side buttons with full-width similar button
                Row(
                  children: [
                    Expanded(
                      child: ButtonUtils.accentButton(
                        onPressed: () => _showImagePickerDialog(cardProvider),
                        label: UITextConstants.changeImage,
                        icon: Icons.edit,
                      ),
                    ),
                    SizedBox(width: AppConfig.defaultPadding),
                    Expanded(
                      child: ButtonUtils.dangerButton(onPressed: cardProvider.clearImage, label: UITextConstants.remove, icon: Icons.delete),
                    ),
                  ],
                ),
                SizedBox(height: AppConfig.defaultPadding),
                SizedBox(
                  width: double.infinity,
                  child: ButtonUtils.secondaryButton(
                    onPressed: () => _checkSimilarCards(cardProvider),
                    label: 'Check Similar Cards',
                    icon: Icons.search,
                  ),
                ),
              ],
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
                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                      border: Border.all(color: AppConfig.grey300, style: BorderStyle.solid),
                    ),
                    child: InkWell(
                      onTap: () => _showImagePickerDialog(cardProvider),
                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: AppConfig.iconSizeXLarge, color: AppConfig.grey600),
                          SizedBox(height: AppConfig.spacingSmall),
                          Text(UITextConstants.tapToUploadImage, style: ResponsiveText.getBody(context).copyWith(color: AppConfig.textColorMuted)),
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
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: AppConfig.primaryColor, size: AppConfig.iconSizeLarge),
                SizedBox(width: AppConfig.smallPadding),
                Text(UITextConstants.cardDetails, style: ResponsiveText.getTitle(context)),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),

            // Cost Price
            TextFormField(
              controller: _costPriceController,
              decoration: InputDecoration(
                labelText: UITextConstants.costPrice,
                hintText: UITextConstants.costPriceHint,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                labelStyle: ResponsiveText.getBody(context),
                hintStyle: ResponsiveText.getCaption(context),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return UITextConstants.pleaseEnterCostPrice;
                }
                if (double.tryParse(value) == null) {
                  return UITextConstants.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            SizedBox(height: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),

            // Sell Price
            TextFormField(
              controller: _sellPriceController,
              decoration: InputDecoration(
                labelText: UITextConstants.sellPrice,
                hintText: UITextConstants.sellPriceHint,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.sell),
                labelStyle: ResponsiveText.getBody(context),
                hintStyle: ResponsiveText.getCaption(context),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return UITextConstants.pleaseEnterSellPrice;
                }
                if (double.tryParse(value) == null) {
                  return UITextConstants.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            SizedBox(height: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: UITextConstants.quantity,
                hintText: UITextConstants.quantityHint,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory),
                labelStyle: ResponsiveText.getBody(context),
                hintStyle: ResponsiveText.getCaption(context),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return UITextConstants.pleaseEnterQuantity;
                }
                if (int.tryParse(value) == null) {
                  return UITextConstants.pleaseEnterValidNumber;
                }
                return null;
              },
            ),
            SizedBox(height: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),

            // Max Discount
            TextFormField(
              controller: _maxDiscountController,
              decoration: InputDecoration(
                labelText: UITextConstants.maxDiscount,
                hintText: UITextConstants.maxDiscountHint,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.discount),
                labelStyle: ResponsiveText.getBody(context),
                hintStyle: ResponsiveText.getCaption(context),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return UITextConstants.pleaseEnterMaxDiscount;
                }
                if (double.tryParse(value) == null) {
                  return UITextConstants.pleaseEnterValidNumber;
                }
                final discount = double.parse(value);
                if (discount < 0 || discount > 100) {
                  return UITextConstants.discountRange;
                }
                return null;
              },
            ),
            SizedBox(height: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),

            // Vendor Dropdown
            Consumer<VendorProvider>(
              builder: (context, vendorProvider, child) {
                if (vendorProvider.isLoading) {
                  return const Center(child: LoadingWidget());
                }

                if (vendorProvider.vendors.isEmpty) {
                  return Text(UITextConstants.noVendorsAvailable, style: ResponsiveText.getCaption(context));
                }

                return DropdownButtonFormField<String>(
                  value: _selectedVendorId,
                  decoration: InputDecoration(
                    labelText: UITextConstants.selectVendor,
                    hintText: UITextConstants.chooseVendorHint,
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.people),
                    labelStyle: ResponsiveText.getBody(context),
                    hintStyle: ResponsiveText.getCaption(context),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return UITextConstants.pleaseSelectVendor;
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
    return ButtonUtils.fullWidthPrimaryButton(
      onPressed: _handleSubmit,
      label: UITextConstants.addCard,
      icon: Icons.add,
      isLoading: cardProvider.isLoading,
    );
  }

  void _showImagePickerDialog(CardProvider cardProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UITextConstants.selectImageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(UITextConstants.galleryTitle),
              onTap: () {
                Navigator.pop(context);
                _uploadDummyImage(cardProvider);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(UITextConstants.cameraTitle),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cardProvider = context.read<CardProvider>();

    // Use selected image URL or a default one
    final imageUrl = cardProvider.selectedImageUrl ?? 'https://t4.ftcdn.net/jpg/05/08/65/87/360_F_508658796_Np78KNMINjP6CemujX79bJsOWOTRbNCW.jpg';

    // Check for similar cards first
    final similarCards = await cardProvider.getSimilarCards(imageUrl);

    if (similarCards.isNotEmpty && mounted) {
      // Show dialog with similar cards found
      final shouldProceed = await _showSimilarCardsDialog(similarCards.length);
      if (!shouldProceed) return;
    }

    final success = await cardProvider.createCard(
      image: imageUrl,
      costPrice: double.parse(_costPriceController.text),
      sellPrice: double.parse(_sellPriceController.text),
      quantity: int.parse(_quantityController.text),
      maxDiscount: double.parse(_maxDiscountController.text),
      vendorId: _selectedVendorId!,
    );

    if (success && mounted) {
      // Navigate back to cards page
      context.go(RouteConstants.inventory);
    }
  }

  Future<bool> _showSimilarCardsDialog(int count) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Similar Cards Found'),
            content: Text('$count similar cards found. Would you like to view them or continue creating a new card?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Continue Creating')),
              ButtonUtils.primaryButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  context.go(RouteConstants.similarCards);
                },
                label: 'View $count Similar Cards',
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _checkSimilarCards(CardProvider cardProvider) async {
    if (cardProvider.selectedImageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please upload an image first'), backgroundColor: AppConfig.errorColor));
      return;
    }

    final similarCards = await cardProvider.getSimilarCards(cardProvider.selectedImageUrl!);

    if (similarCards.isNotEmpty && mounted) {
      final shouldView = await _showSimilarCardsDialog(similarCards.length);
      if (shouldView) {
        context.go(RouteConstants.similarCards);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No similar cards found'), backgroundColor: AppConfig.successColor));
    }
  }
}
