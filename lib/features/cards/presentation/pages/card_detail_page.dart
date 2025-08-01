import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

class CardDetailPage extends StatefulWidget {
  final String cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  CardViewModel? _card;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCardDetails();
  }

  Future<void> _loadCardDetails() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      AppLogger.service('CardDetailPage', 'Loading card details for ID: ${widget.cardId}');

      final cardProvider = context.read<CardProvider>();
      final card = await cardProvider.getCardById(widget.cardId);

      AppLogger.debug('CardDetailPage: Card data received: $card');
      AppLogger.debug('CardDetailPage: Card is null: ${card == null}');
      AppLogger.debug('CardDetailPage: Card type: ${card.runtimeType}');

      if (mounted) {
        setState(() {
          _card = card;
          // If card is null, set an error message
          if (card == null) {
            _errorMessage = 'Card not found or no longer available';
          }
        });
      }
    } catch (e) {
      AppLogger.errorCaught('CardDetailPage._loadCardDetails', e.toString(), errorObject: e);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UITextConstants.cardDetails),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.inventory)),
        actions: _buildActionButtons(),
      ),
      body: _card == null
          ? const LoadingWidget()
          : SingleChildScrollView(
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
                          _buildCardImage(),
                          SizedBox(height: context.responsiveSpacing),

                          // Content Layout
                          if (context.isDesktop) ...[
                            // Desktop: Side-by-side layout
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: _buildCardInfo()),
                                Expanded(flex: 1, child: _buildBarcodeSection()),
                              ],
                            ),
                          ] else ...[
                            // Mobile/Tablet: Stacked layout
                            _buildCardInfo(),
                            SizedBox(height: context.responsiveSpacing),
                            _buildBarcodeSection(),
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
            ),
    );
  }

  List<Widget> _buildActionButtons() {
    if (_card == null) return [];

    return [
      Consumer<PermissionProvider>(
        builder: (context, permissionProvider, child) {
          final canEdit = permissionProvider.canUpdate('card');
          final canDelete = permissionProvider.canDelete('card');

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit) IconButton(icon: const Icon(Icons.edit), onPressed: _showEditCardDialog, tooltip: UITextConstants.edit),
              if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showDeleteConfirmation,
                  tooltip: UITextConstants.delete,
                  color: AppConfig.errorColor,
                ),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildCardHeader() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _card!.isActive ? AppConfig.successColor : AppConfig.grey400,
                borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
              ),
              child: Icon(Icons.credit_card, size: 30, color: AppConfig.textColorPrimary),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Barcode: ${_card!.barcode}', style: ResponsiveText.getHeadline(context)),
                  SizedBox(height: AppConfig.smallPadding),
                  Text('ID: ${_card!.id}', style: ResponsiveText.getSubtitle(context).copyWith(color: AppConfig.textColorSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    if (_card == null) return const SizedBox.shrink();

    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Barcode', _card!.barcode),
            SizedBox(height: AppConfig.smallPadding),
            _buildInfoRow('Vendor ID', _card!.vendorId),
            _buildInfoRow('Sell Price', '₹${_card!.sellPrice}'),
            _buildInfoRow('Cost Price', '₹${_card!.costPrice}'),
            _buildInfoRow('Max Discount', '-₹${_card!.maxDiscount}'),
            _buildInfoRow('Quantity', _card!.quantity.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeSection() {
    if (_card == null) return const SizedBox.shrink();

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
                      data: _card!.barcode,
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

  Widget _buildCardImage() {
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
                child: _card!.image.isNotEmpty
                    ? Image.network(
                        _card!.image,
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

  Widget _buildCardStats() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.isDesktop) ...[
              // Desktop: 2x2 grid
              Row(
                children: [
                  Expanded(child: _buildStatCard('Profit Margin', _card!.formattedProfitMargin, Icons.trending_up, AppConfig.successColor)),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(child: _buildStatCard('Total Value', _card!.formattedTotalValue, Icons.attach_money, AppConfig.primaryColor)),
                ],
              ),
              SizedBox(height: AppConfig.defaultPadding),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Available', '${_card!.quantity}', Icons.inventory, AppConfig.warningColor)),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(child: _buildStatCard('Max Discount', '₹${_card!.maxDiscount}', Icons.discount, AppConfig.primaryColor)),
                ],
              ),
            ] else ...[
              // Mobile/Tablet: 2x2 grid with smaller spacing
              Row(
                children: [
                  Expanded(child: _buildStatCard('Profit Margin', _card!.formattedProfitMargin, Icons.trending_up, AppConfig.successColor)),
                  SizedBox(width: AppConfig.smallPadding),
                  Expanded(child: _buildStatCard('Total Value', _card!.formattedTotalValue, Icons.attach_money, AppConfig.primaryColor)),
                ],
              ),
              SizedBox(height: AppConfig.smallPadding),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Available', '${_card!.quantity}', Icons.inventory, AppConfig.warningColor)),
                  SizedBox(width: AppConfig.smallPadding),
                  Expanded(child: _buildStatCard('Max Discount', '₹${_card!.maxDiscount}', Icons.discount, AppConfig.primaryColor)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.isDesktop ? 28 : 24),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: ResponsiveText.getTitle(context).copyWith(fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            title,
            style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.textColorSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog() {
    // TODO: Implement edit card dialog
    SnackbarUtils.showInfo(context, 'Edit card functionality coming soon!');
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete card ${_card!.barcode}? This action cannot be undone.'),
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
      SnackbarUtils.showInfo(context, 'Delete card functionality coming soon!');
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to delete card: $e');
      }
    }
  }
}
