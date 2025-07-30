import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/models/card_model.dart' as card_model;
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

class CardDetailPage extends StatefulWidget {
  final String cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  card_model.Card? _card;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCardDetails();
  }

  Future<void> _loadCardDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔍 Loading card details for ID: ${widget.cardId}');

      final cardProvider = context.read<CardProvider>();
      final card = await cardProvider.getCardById(widget.cardId);

      print('📦 Card data received: $card');
      print('📦 Card is null: ${card == null}');
      print('📦 Card type: ${card.runtimeType}');

      if (mounted) {
        setState(() {
          _card = card;
          _isLoading = false;
          // If card is null, set an error message
          if (card == null) {
            _errorMessage = 'Card not found or no longer available';
          }
        });
      }
    } catch (e) {
      print('❌ Error loading card details: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: 0,
      destinations: const [NavigationDestination(icon: Icon(Icons.inventory), label: 'Cards')],
      onDestinationSelected: (index) {},
      child: _buildCardDetailContent(),
    );
  }

  Widget _buildCardDetailContent() {
    return Padding(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button and actions
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.inventory)),
              SizedBox(width: AppConfig.smallPadding),
              Expanded(
                child: PageHeader(title: 'Card Details', actions: _buildActionButtons()),
              ),
            ],
          ),
          SizedBox(height: AppConfig.largePadding),

          // Content
          Expanded(child: _buildContent()),
        ],
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
              if (canEdit) ActionButton(label: 'Edit', icon: Icons.edit, onPressed: _showEditCardDialog),
              if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
              if (canDelete)
                ActionButton(label: 'Delete', icon: Icons.delete, onPressed: _showDeleteConfirmation, backgroundColor: AppConfig.errorColor),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildContent() {
    if (_card == null) {
      return const Center(child: SpinKitDoubleBounce(color: AppConfig.primaryColor));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Image - First thing displayed
          _buildCardImage(),
          SizedBox(height: AppConfig.largePadding),

          // Card Information
          _buildCardInfo(),
          SizedBox(height: AppConfig.largePadding),

          // Card Statistics
          _buildCardStats(),
        ],
      ),
    );
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
                  Text(
                    'Barcode: ${_card!.barcode}',
                    style: TextStyle(fontSize: AppConfig.fontSizeXl, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Text(
                    'ID: ${_card!.id}',
                    style: TextStyle(fontSize: AppConfig.fontSizeLg, color: AppConfig.textColorSecondary),
                  ),
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
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Information', style: AppConfig.headlineStyle),
                  SizedBox(height: AppConfig.defaultPadding),

                  _buildInfoRow('Barcode', _card!.barcode),
                  SizedBox(height: AppConfig.smallPadding),

                  // Small barcode widget for scanner
                  _buildInfoRow('Vendor ID', _card!.vendorId),
                  _buildInfoRow('Sell Price', '₹${_card!.sellPrice}'),
                  _buildInfoRow('Cost Price', '₹${_card!.costPrice}'),
                  _buildInfoRow('Max Discount', '${_card!.maxDiscount}%'),
                  _buildInfoRow('Quantity', _card!.quantity.toString()),
                  if (_card!.perceptualHash.isNotEmpty) _buildInfoRow('Perceptual Hash', _card!.perceptualHash),
                ],
              ),
            ),
            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                border: Border.all(color: AppConfig.grey400),
              ),
              child: Center(
                // Added Center widget to vertically center the barcode
                child: Padding(
                  padding: EdgeInsets.all(16.0), // More white padding
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: _card!.barcode,
                    drawText: true,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.black87),
                    color: Colors.black,
                    width: 300, // Increased width for better scanning
                    height: 100, // Adjusted for padding
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
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardImage() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card Image', style: AppConfig.headlineStyle),
            SizedBox(height: AppConfig.defaultPadding),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
                child: _card!.image.isNotEmpty
                    ? Image.network(
                        _card!.image,
                        width: context.getResponsiveImageWidth(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive width
                        height: context.getResponsiveImageHeight(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive height
                        fit: BoxFit.contain, // Changed from cover to contain to prevent cropping
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: context.getResponsiveImageWidth(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive width
                            height: context.getResponsiveImageHeight(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive height
                            decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                            child: Icon(Icons.image, color: AppConfig.grey600, size: 50),
                          );
                        },
                      )
                    : Container(
                        width: context.getResponsiveImageWidth(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive width
                        height: context.getResponsiveImageHeight(desktopFraction: 0.3, mobileFraction: 0.6), // Responsive height
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
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Profit Margin',
                    '${((_card!.sellPriceAsDouble - _card!.costPriceAsDouble) / _card!.sellPriceAsDouble * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    AppConfig.successColor,
                  ),
                ),
                SizedBox(width: AppConfig.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    'Total Value',
                    '₹${(_card!.sellPriceAsDouble * _card!.quantity).toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppConfig.primaryColor,
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            title,
            style: TextStyle(fontSize: AppConfig.fontSizeSm, color: AppConfig.textColorSecondary),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCard();
            },
            style: TextButton.styleFrom(foregroundColor: AppConfig.errorColor),
            child: const Text('Delete'),
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
