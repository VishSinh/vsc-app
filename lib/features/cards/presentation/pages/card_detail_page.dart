import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';

class CardDetailPage extends StatefulWidget {
  final String cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadCardDetails();
  }

  void _loadCardDetails() {
    final cardProvider = context.read<CardProvider>();
    cardProvider.getCardById(widget.cardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UITextConstants.cardDetails),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.inventory)),
        actions: [_buildActionButtons()],
      ),
      body: _buildCardDetailContent(),
    );
  }

  Widget _buildCardDetailContent() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cardProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cardProvider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadCardDetails, child: const Text('Retry')),
              ],
            ),
          );
        }

        final card = cardProvider.currentCard;
        if (card == null) {
          return const Center(child: Text('Card not found'));
        }

        return SingleChildScrollView(
          padding: context.responsivePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: context.responsivePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Image
                      _buildCardImage(card),
                      SizedBox(height: context.responsiveSpacing),

                      // Content Layout
                      if (context.isDesktop) ...[
                        // Desktop: Side-by-side layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildCardInfo(card)),
                            Expanded(flex: 1, child: _buildBarcodeSection(card)),
                          ],
                        ),
                      ] else ...[
                        // Mobile/Tablet: Stacked layout
                        _buildCardInfo(card),
                        SizedBox(height: context.responsiveSpacing),
                        _buildBarcodeSection(card),
                      ],
                      SizedBox(height: context.responsiveSpacing),

                      // Card Statistics
                      // _buildCardStats(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final card = cardProvider.currentCard;
        if (card == null) return const SizedBox.shrink();

        return Consumer<PermissionProvider>(
          builder: (context, permissionProvider, child) {
            final canEdit = permissionProvider.canUpdate('card');
            final canDelete = permissionProvider.canDelete('card');

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit) IconButton(icon: const Icon(Icons.edit), onPressed: _showEditCardDialog, tooltip: UITextConstants.edit),
                if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
                if (canDelete) IconButton(icon: const Icon(Icons.delete), onPressed: _showDeleteCardDialog, tooltip: UITextConstants.delete),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCardImage(CardViewModel card) {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
                child: card.image.isNotEmpty
                    ? Image.network(
                        card.image,
                        width: context.isDesktop
                            ? context.getResponsiveImageWidth(desktopFraction: 0.4, mobileFraction: 0.8)
                            : context.getResponsiveImageWidth(desktopFraction: 0.8, mobileFraction: 0.9),
                        height: context.isDesktop
                            ? context.getResponsiveImageHeight(desktopFraction: 0.4, mobileFraction: 0.8)
                            : context.getResponsiveImageHeight(desktopFraction: 0.8, mobileFraction: 0.9),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: context.isDesktop
                                ? context.getResponsiveImageWidth(desktopFraction: 0.4, mobileFraction: 0.8)
                                : context.getResponsiveImageWidth(desktopFraction: 0.8, mobileFraction: 0.9),
                            height: context.isDesktop
                                ? context.getResponsiveImageHeight(desktopFraction: 0.4, mobileFraction: 0.8)
                                : context.getResponsiveImageHeight(desktopFraction: 0.8, mobileFraction: 0.9),
                            decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                            child: Icon(Icons.image, color: AppConfig.grey600, size: 50),
                          );
                        },
                      )
                    : Container(
                        width: context.isDesktop
                            ? context.getResponsiveImageWidth(desktopFraction: 0.4, mobileFraction: 0.8)
                            : context.getResponsiveImageWidth(desktopFraction: 0.8, mobileFraction: 0.9),
                        height: context.isDesktop
                            ? context.getResponsiveImageHeight(desktopFraction: 0.4, mobileFraction: 0.8)
                            : context.getResponsiveImageHeight(desktopFraction: 0.8, mobileFraction: 0.9),
                        decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                        child: Icon(Icons.image, color: AppConfig.grey600, size: 50),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(CardViewModel card) {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Barcode', card.barcode),
            SizedBox(height: AppConfig.smallPadding),
            _buildInfoRow('Vendor ID', card.vendorId),
            _buildInfoRow('Sell Price', '₹${card.sellPrice}'),
            _buildInfoRow('Cost Price', '₹${card.costPrice}'),
            _buildInfoRow('Max Discount', '-₹${card.maxDiscount}'),
            _buildInfoRow('Quantity', card.quantity.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeSection(CardViewModel card) {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: context.isDesktop ? 500 : double.infinity,
                height: context.isDesktop ? 120 : 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                  border: Border.all(color: AppConfig.grey400),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConfig.smallPadding),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: card.barcode,
                      drawText: true,
                      style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600, color: AppConfig.black87),
                      color: Colors.black,
                      width: context.isDesktop ? 580 : 500,
                      height: context.isDesktop ? 100 : 100,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isDesktop ? 140 : 120,
            child: Text(
              label,
              style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog() {
    // TODO: Implement edit card dialog
    // SnackbarUtils.showInfo(context, 'Edit card functionality coming soon!'); // Removed as per new_code
  }

  void _showDeleteCardDialog() {
    final cardProvider = context.read<CardProvider>();
    final card = cardProvider.currentCard;
    if (card == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete card ${card.barcode}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCard();
            },
            style: TextButton.styleFrom(foregroundColor: AppConfig.errorColor),
            child: Text(UITextConstants.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard() async {
    try {
      // TODO: Implement delete card functionality
      // SnackbarUtils.showInfo(context, 'Delete card functionality coming soon!'); // Removed as per new_code
    } catch (e) {
      if (mounted) {
        // SnackbarUtils.showError(context, 'Failed to delete card: $e'); // Removed as per new_code
      }
    }
  }
}
