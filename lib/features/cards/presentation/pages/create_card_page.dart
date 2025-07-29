import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';

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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.cards)),
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConfig.largePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConfig.maxWidthXLarge),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.largePadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(UITextConstants.createCardTitle, style: AppConfig.headlineStyle.copyWith(color: AppConfig.primaryColor)),
                        const SizedBox(height: AppConfig.smallPadding),
                        Text(UITextConstants.createCardSubtitle, style: AppConfig.subtitleStyle),
                        const SizedBox(height: AppConfig.largePadding),

                        // Content Layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Use row layout for larger screens (width > 800)
                            if (constraints.maxWidth > AppConfig.maxWidthLarge) {
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
                Icon(Icons.image, color: AppConfig.primaryColor, size: AppConfig.iconSizeLarge),
                const SizedBox(width: AppConfig.smallPadding),
                Text(UITextConstants.cardImage, style: AppConfig.titleStyle),
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
              const SizedBox(height: AppConfig.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ButtonUtils.accentButton(
                      onPressed: () => _showImagePickerDialog(cardProvider),
                      label: UITextConstants.changeImage,
                      icon: Icons.edit,
                    ),
                  ),
                  const SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: ButtonUtils.dangerButton(onPressed: cardProvider.clearImage, label: UITextConstants.remove, icon: Icons.delete),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.defaultPadding),
              ButtonUtils.secondaryButton(onPressed: () => _checkSimilarCards(cardProvider), label: 'Check Similar Cards', icon: Icons.search),
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
                          const SizedBox(height: AppConfig.spacingSmall),
                          Text(UITextConstants.tapToUploadImage, style: AppConfig.bodyStyle.copyWith(color: AppConfig.textColorMuted)),
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
                Icon(Icons.edit_note, color: AppConfig.primaryColor, size: AppConfig.iconSizeLarge),
                const SizedBox(width: AppConfig.smallPadding),
                Text(UITextConstants.cardDetails, style: AppConfig.titleStyle),
              ],
            ),
            const SizedBox(height: AppConfig.defaultPadding),

            // Cost Price
            TextFormField(
              controller: _costPriceController,
              decoration: InputDecoration(
                labelText: UITextConstants.costPrice,
                hintText: UITextConstants.costPriceHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
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
            const SizedBox(height: AppConfig.defaultPadding),

            // Sell Price
            TextFormField(
              controller: _sellPriceController,
              decoration: InputDecoration(
                labelText: UITextConstants.sellPrice,
                hintText: UITextConstants.sellPriceHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.sell),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
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
            const SizedBox(height: AppConfig.defaultPadding),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: UITextConstants.quantity,
                hintText: UITextConstants.quantityHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.inventory),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
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
            const SizedBox(height: AppConfig.defaultPadding),

            // Max Discount
            TextFormField(
              controller: _maxDiscountController,
              decoration: InputDecoration(
                labelText: UITextConstants.maxDiscount,
                hintText: UITextConstants.maxDiscountHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.discount),
                labelStyle: AppConfig.bodyStyle,
                hintStyle: AppConfig.captionStyle,
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
            const SizedBox(height: AppConfig.defaultPadding),

            // Vendor Dropdown
            Consumer<VendorProvider>(
              builder: (context, vendorProvider, child) {
                if (vendorProvider.isLoading) {
                  return const Center(
                    child: SpinKitDoubleBounce(color: AppConfig.primaryColor, size: AppConfig.loadingIndicatorSize),
                  );
                }

                if (vendorProvider.vendors.isEmpty) {
                  return Text(UITextConstants.noVendorsAvailable, style: AppConfig.captionStyle);
                }

                return DropdownButtonFormField<String>(
                  value: _selectedVendorId,
                  decoration: InputDecoration(
                    labelText: UITextConstants.selectVendor,
                    hintText: UITextConstants.chooseVendorHint,
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
              leading: const Icon(Icons.photo_library),
              title: Text(UITextConstants.galleryTitle),
              onTap: () {
                Navigator.pop(context);
                _uploadDummyImage(cardProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
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
      context.go(RouteConstants.cards);
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  context.go(RouteConstants.similarCards);
                },
                child: Text('View $count Similar Cards'),
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
