import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/providers/create_card_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/enums/card_type.dart';

class CreateCardPage extends StatefulWidget {
  final CreateCardProvider? createCardProvider;

  const CreateCardPage({super.key, this.createCardProvider});

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
  CardType _selectedCardType = CardType.single;

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
    final cardProvider = widget.createCardProvider ?? CreateCardProvider();

    return ChangeNotifierProvider.value(
      value: cardProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(UITextConstants.createCard),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: Consumer<CreateCardProvider>(
          builder: (context, cardProvider, child) {
            return SingleChildScrollView(
              padding: context.responsivePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection(CreateCardProvider cardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFormFields(),
        SizedBox(height: context.isMobile ? AppConfig.defaultPadding : AppConfig.largePadding),
        _buildSubmitButton(cardProvider),
      ],
    );
  }

  Widget _buildImageSection(CreateCardProvider cardProvider) {
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

            if (cardProvider.formModel.image != null) ...[
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
                      child: cardProvider.formModel.image != null
                          ? _buildImageWidget(cardProvider.formModel.image!)
                          : Container(
                              color: AppConfig.grey300,
                              child: const Icon(Icons.error, color: AppConfig.red, size: AppConfig.iconSizeXLarge),
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
                  child: ButtonUtils.dangerButton(
                    onPressed: () => cardProvider.clearImage(),
                    label: UITextConstants.remove,
                    icon: Icons.delete,
                    isLoading: cardProvider.isLoading,
                  ),
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
                      child: ButtonUtils.dangerButton(
                        onPressed: () => cardProvider.clearImage(),
                        label: UITextConstants.remove,
                        icon: Icons.delete,
                        isLoading: cardProvider.isLoading,
                      ),
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
                          Text(
                            UITextConstants.tapToUploadImage,
                            style: ResponsiveText.getBody(context).copyWith(color: AppConfig.textColorMuted),
                          ),
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

            // Card Type
            DropdownButtonFormField<CardType>(
              value: _selectedCardType,
              decoration: InputDecoration(
                labelText: UITextConstants.cardType,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
                labelStyle: ResponsiveText.getBody(context),
                hintStyle: ResponsiveText.getCaption(context),
              ),
              items: CardType.values
                  .map(
                    (ct) => DropdownMenuItem<CardType>(
                      value: ct,
                      child: Text(ct.displayText, style: ResponsiveText.getBody(context)),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCardType = val ?? CardType.single),
            ),
            SizedBox(height: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),

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

  Widget _buildSubmitButton(CreateCardProvider cardProvider) {
    return ButtonUtils.fullWidthPrimaryButton(
      onPressed: _handleSubmit,
      label: UITextConstants.addCard,
      icon: Icons.add,
      isLoading: cardProvider.isLoading,
    );
  }

  void _showImagePickerDialog(CreateCardProvider cardProvider) {
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
                _pickImage(cardProvider, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(UITextConstants.cameraTitle),
              onTap: () {
                Navigator.pop(context);
                _pickImage(cardProvider, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(CreateCardProvider cardProvider, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (image != null) {
        cardProvider.uploadImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppConfig.errorColor));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cardProvider = widget.createCardProvider ?? context.read<CreateCardProvider>();

    // Check if image is selected
    if (cardProvider.formModel.image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an image first'), backgroundColor: AppConfig.errorColor));
      return;
    }

    // Update form model with form data
    cardProvider.updateFormField(
      costPrice: _costPriceController.text,
      sellPrice: _sellPriceController.text,
      quantity: _quantityController.text,
      maxDiscount: _maxDiscountController.text,
      vendorId: _selectedVendorId!,
      cardType: _selectedCardType,
    );

    // Check for similar cards first
    cardProvider.setContext(context);
    await cardProvider.searchSimilarCards(cardProvider.formModel.image!);

    if (cardProvider.similarCards.isNotEmpty && mounted) {
      // Show dialog with similar cards found
      final shouldViewSimilar = await _showSimilarCardsDialog(cardProvider.similarCards.length);
      if (shouldViewSimilar) {
        // User chose to view similar cards, so return early
        return;
      }
      // User chose to continue creating, so proceed with card creation
    }

    // Create the card
    final barcode = await cardProvider.createCard();

    // Handle navigation in UI layer
    if (barcode != null && mounted) {
      context.push('${RouteConstants.bluetoothPrint}?barcode=$barcode');
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
                  final cardProvider = widget.createCardProvider ?? context.read<CreateCardProvider>();
                  context.push(RouteConstants.similarCards, extra: cardProvider);
                },
                label: 'View $count Similar Cards',
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _checkSimilarCards(CreateCardProvider cardProvider) async {
    if (cardProvider.formModel.image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please upload an image first'), backgroundColor: AppConfig.errorColor));
      return;
    }

    await cardProvider.searchSimilarCards(cardProvider.formModel.image!);

    if (cardProvider.similarCards.isNotEmpty && mounted) {
      final shouldView = await _showSimilarCardsDialog(cardProvider.similarCards.length);
      if (shouldView) {
        final cardProvider = widget.createCardProvider ?? context.read<CreateCardProvider>();
        context.go(RouteConstants.similarCards, extra: cardProvider);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No similar cards found'), backgroundColor: AppConfig.successColor));
    }
  }

  /// Build image widget with platform-specific handling
  Widget _buildImageWidget(XFile imageFile) {
    if (kIsWeb) {
      // For web, use Image.memory with bytes
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppConfig.grey300,
                  child: const Icon(Icons.error, color: AppConfig.red, size: AppConfig.iconSizeXLarge),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Container(
              color: AppConfig.grey300,
              child: const Icon(Icons.error, color: AppConfig.red, size: AppConfig.iconSizeXLarge),
            );
          } else {
            return Container(color: AppConfig.grey300, child: const CircularProgressIndicator());
          }
        },
      );
    } else {
      // For mobile, use Image.file
      return Image.file(
        File(imageFile.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppConfig.grey300,
            child: const Icon(Icons.error, color: AppConfig.red, size: AppConfig.iconSizeXLarge),
          );
        },
      );
    }
  }
}
