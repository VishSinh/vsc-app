import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/cards/presentation/widgets/edit_card_dialog.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';

class CardDetailPage extends StatefulWidget {
  final String cardId;
  final CardDetailProvider? cardProvider;

  const CardDetailPage({super.key, required this.cardId, this.cardProvider});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late final CardDetailProvider _cardProvider;

  @override
  void initState() {
    super.initState();
    _cardProvider = widget.cardProvider ?? CardDetailProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCardDetails();
      }
    });
  }

  void _loadCardDetails() {
    _cardProvider.getCardById(widget.cardId);
  }

  // Printing is handled by BluetoothPrintService

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cardProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(UITextConstants.cardDetails),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          actions: [_buildActionButtons()],
        ),
        body: _buildCardDetailContent(),
      ),
    );
  }

  Widget _buildCardDetailContent() {
    return Consumer<CardDetailProvider>(
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
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CardDetailProvider>(
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
                if (canEdit)
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditCardDialog(cardProvider, card), tooltip: UITextConstants.edit),
                if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteCardDialog(cardProvider, card),
                    tooltip: UITextConstants.delete,
                  ),
                // Print button
                SizedBox(width: AppConfig.smallPadding),
                IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Print Barcode',
                  onPressed: () {
                    context.go('${RouteConstants.bluetoothPrint}?barcode=${card.barcode}');
                  },
                ),
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
            _buildInfoRow('Vendor', card.vendorName),
            _buildInfoRow('Sell Price', '₹${card.sellPrice}'),
            _buildInfoRow('Cost Price', '₹${card.costPrice}'),
            _buildInfoRow('Max Discount', '₹${card.maxDiscount}', valueColor: AppConfig.errorColor),
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

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
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
            child: Text(
              value,
              style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600, color: valueColor ?? AppConfig.textColorPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(CardDetailProvider cardProvider, CardViewModel card) {
    // Load vendors for dropdown
    final vendorProvider = context.read<VendorProvider>();
    vendorProvider.loadVendors();

    showDialog(
      context: context,
      builder: (context) =>
          EditCardDialog(card: card, cardProvider: cardProvider, vendorProvider: vendorProvider, onCardUpdated: () => _loadCardDetails()),
    );
  }

  void _showDeleteCardDialog(CardDetailProvider cardProvider, CardViewModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete card ${card.barcode}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
          TextButton(
            onPressed: cardProvider.isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    _deleteCard(cardProvider, card);
                  },
            style: TextButton.styleFrom(foregroundColor: AppConfig.errorColor),
            child: cardProvider.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppConfig.errorColor)),
                  )
                : Text(UITextConstants.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard(CardDetailProvider cardProvider, CardViewModel card) async {
    final success = await cardProvider.deleteCard(card.id);

    if (success && mounted) {
      context.go(RouteConstants.inventory);
    }
  }
}
