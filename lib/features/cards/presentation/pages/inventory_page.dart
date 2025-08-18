import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCardsIfNeeded();
        _initializePermissions();
      }
    });
  }

  void _loadCardsIfNeeded() {
    final cardProvider = context.read<CardListProvider>();
    if (cardProvider.cards.isEmpty) {
      _loadCards();
    }
  }

  void _loadCards() {
    final cardProvider = context.read<CardListProvider>();
    cardProvider.setContext(context);
    cardProvider.loadCards();
  }

  void _initializePermissions() {
    final permissionProvider = context.read<PermissionProvider>();
    if (!permissionProvider.isInitialized) {
      permissionProvider.initializePermissions().catchError((error) {
        // Handle error if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardDetailProvider(),
      child: Consumer<CardListProvider>(
        builder: (context, cardProvider, child) {
          return _buildInventoryContent();
        },
      ),
    );
  }

  Widget _buildInventoryContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InventoryActionButtons(),
          const SizedBox(height: 16),
          Expanded(child: _buildCardsListSection()),
        ],
      ),
    );
  }

  Widget _buildCardsListSection() {
    return Consumer<CardListProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const LoadingWidget(message: 'Loading cards...');
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildCardsList(),
            if (cardProvider.pagination != null)
              Positioned(
                bottom: 10,
                child: PaginationWidget(
                  currentPage: cardProvider.pagination?.currentPage ?? 1,
                  totalPages: cardProvider.pagination?.totalPages ?? 1,
                  hasPrevious: cardProvider.pagination?.hasPrevious ?? false,
                  hasNext: cardProvider.hasMoreCards,
                  onPreviousPage: cardProvider.pagination?.hasPrevious ?? false ? () => cardProvider.loadPreviousPage() : null,
                  onNextPage: cardProvider.hasMoreCards ? () => cardProvider.loadNextPage() : null,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCardsList() {
    return Consumer<CardListProvider>(
      builder: (context, cardProvider, child) {
        final filteredCards = cardProvider.getFilteredCards(cardProvider.searchQuery);

        if (filteredCards.isEmpty) {
          return const EmptyStateWidget(message: 'No cards found', icon: Icons.inventory_2_outlined);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final gridConfig = _calculateGridConfig(constraints.maxWidth);

            return GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridConfig.crossAxisCount,
                childAspectRatio: gridConfig.childAspectRatio,
                crossAxisSpacing: AppConfig.defaultPadding,
                mainAxisSpacing: AppConfig.defaultPadding,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];
                return InventoryCardItem(card: card);
              },
              padding: const EdgeInsets.only(bottom: 80),
            );
          },
        );
      },
    );
  }

  GridConfig _calculateGridConfig(double availableWidth) {
    const cardWidth = 280.0; // Fixed card width for desktop
    const mobileCardWidth = 160.0; // Fixed card width for mobile
    const childAspectRatio = 0.8;

    final effectiveCardWidth = context.isDesktop ? cardWidth : mobileCardWidth;
    final crossAxisCount = (availableWidth / (effectiveCardWidth + AppConfig.defaultPadding)).floor();
    final maxCrossAxisCount = context.isDesktop ? 6 : 2;
    final actualCrossAxisCount = crossAxisCount.clamp(1, maxCrossAxisCount);

    return GridConfig(crossAxisCount: actualCrossAxisCount, childAspectRatio: childAspectRatio);
  }
}

class GridConfig {
  final int crossAxisCount;
  final double childAspectRatio;

  const GridConfig({required this.crossAxisCount, required this.childAspectRatio});
}

class InventoryActionButtons extends StatelessWidget {
  const InventoryActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return _buildMobileButtons(context);
    } else {
      return _buildDesktopButtons(context);
    }
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(context, icon: Icons.image_search, color: Colors.blue[600]!, onPressed: () => _onSearchByImage(context)),
        const SizedBox(width: 8),
        _buildActionButton(context, icon: Icons.qr_code_scanner, color: Colors.green[600]!, onPressed: () => _onScanBarcode(context)),
        const SizedBox(width: 8),
        _buildActionButton(context, icon: Icons.filter_list, color: Colors.orange[600]!, onPressed: () => _onFilters(context)),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButtonWithText(
          context,
          icon: Icons.image_search,
          label: 'Search by Image',
          color: Colors.blue[600]!,
          onPressed: () => _onSearchByImage(context),
        ),
        const SizedBox(width: 8),
        _buildActionButtonWithText(
          context,
          icon: Icons.qr_code_scanner,
          label: 'Scan Barcode',
          color: Colors.green[600]!,
          onPressed: () => _onScanBarcode(context),
        ),
        const SizedBox(width: 8),
        _buildActionButtonWithText(
          context,
          icon: Icons.filter_list,
          label: 'Filters',
          color: Colors.orange[600]!,
          onPressed: () => _onFilters(context),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(icon, size: 24),
      ),
    );
  }

  Widget _buildActionButtonWithText(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  void _onSearchByImage(BuildContext context) {
    SnackbarUtils.showInfo(context, 'Search by Image functionality coming soon!');
  }

  void _onScanBarcode(BuildContext context) {
    SnackbarUtils.showInfo(context, 'Barcode scanning functionality coming soon!');
  }

  void _onFilters(BuildContext context) {
    SnackbarUtils.showInfo(context, 'Filters functionality coming soon!');
  }
}

class InventoryCardItem extends StatelessWidget {
  final CardViewModel card;

  const InventoryCardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final cardDetailProvider = context.read<CardDetailProvider>();
          context.pushNamed(RouteConstants.cardDetailRouteName, pathParameters: {'id': card.id}, extra: cardDetailProvider);
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildImageSection(context), _buildContentSection(context)]),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Adjust image height based on screen size
    // Make desktop images more proportional to the card width
    final imageHeight = context.isMobile ? 140.0 : 220.0;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: context.isMobile ? 16 / 9 : 4 / 3,
          child: SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Image.network(
              card.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppConfig.grey300,
                child: Icon(Icons.image_not_supported, color: AppConfig.grey400, size: AppConfig.iconSizeLarge),
              ),
            ),
          ),
        ),
        if (card.quantity <= 5)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'LOW STOCK',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (card.barcode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          card.barcode.length > 8 ? '${card.barcode.substring(0, 8)}...' : card.barcode,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _getProfitMarginColor(card.profitMargin).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '${card.profitMargin.toStringAsFixed(1)}%',
                    style: TextStyle(color: _getProfitMarginColor(card.profitMargin), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final padding = context.isMobile ? 8.0 : AppConfig.defaultPadding;

    // Use more vertical space on desktop to balance the card
    final verticalSpacing = context.isMobile ? 4.0 : 12.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPriceText(context),
                    SizedBox(height: context.isMobile ? 2.0 : 6.0),
                    _buildDiscountText(context),
                  ],
                ),
              ),
              _buildStockIndicator(context),
            ],
          ),
          SizedBox(height: verticalSpacing),
          _buildInfoRow(context),
          // Add extra space at the bottom on desktop
          if (!context.isMobile) SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildPriceText(BuildContext context) {
    // Increase font size on desktop for better proportions
    final textStyle = context.isMobile
        ? ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)
        : ResponsiveText.getTitle(context).copyWith(fontSize: 22, fontWeight: FontWeight.bold);

    return Text('₹${card.sellPrice}', style: textStyle);
  }

  Widget _buildDiscountText(BuildContext context) {
    // Adjust font size for desktop
    final fontSize = context.isMobile ? 10.0 : 14.0;

    return Text(
      context.isMobile ? 'Disc: ₹${card.maxDiscount}' : 'Max Discount: ₹${card.maxDiscount}',
      style: ResponsiveText.getCaption(
        context,
      ).copyWith(color: AppConfig.errorColor, fontSize: fontSize, fontWeight: context.isMobile ? FontWeight.normal : FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStockIndicator(BuildContext context) {
    final color = card.quantity > 10
        ? Colors.green
        : card.quantity > 5
        ? Colors.orange
        : Colors.red;

    // Make stock indicator more prominent on desktop
    final horizontalPadding = context.isMobile ? 6.0 : 12.0;
    final verticalPadding = context.isMobile ? 2.0 : 6.0;
    final fontSize = context.isMobile ? 12.0 : 16.0;
    final borderRadius = context.isMobile ? 4.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${card.quantity}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    // Adjust icon and text sizes for desktop
    final iconSize = context.isMobile ? 12.0 : 18.0;
    final fontSize = context.isMobile ? 10.0 : 14.0;
    final spacing = context.isMobile ? 4.0 : 8.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on_outlined, size: iconSize, color: AppConfig.secondaryColor),
              SizedBox(width: spacing / 2),
              Flexible(
                child: Text(
                  'Cost: ₹${card.costPrice}',
                  style: ResponsiveText.getCaption(
                    context,
                  ).copyWith(fontSize: fontSize, fontWeight: context.isMobile ? FontWeight.normal : FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing),
        Text(
          'Val: ₹${card.totalValue.toStringAsFixed(0)}',
          style: ResponsiveText.getCaption(
            context,
          ).copyWith(fontWeight: FontWeight.bold, fontSize: fontSize, color: context.isMobile ? null : AppConfig.primaryColor),
        ),
      ],
    );
  }

  Color _getProfitMarginColor(double margin) {
    if (margin >= 30) return Colors.green;
    if (margin >= 15) return Colors.orange;
    return Colors.red;
  }
}
