import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/create_card_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
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
          return Column(
            children: [
              Expanded(child: _buildInventoryContent()),
              // Floating action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: _loadCards,
                      backgroundColor: Colors.orange,
                      heroTag: 'reload',
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Refresh', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    Consumer<PermissionProvider>(
                      builder: (context, permissionProvider, child) {
                        if (permissionProvider.canCreate('card')) {
                          return FloatingActionButton.extended(
                            onPressed: () {
                              final createCardProvider = CreateCardProvider();
                              context.push(RouteConstants.createCard, extra: createCardProvider);
                            },
                            backgroundColor: AppConfig.primaryColor,
                            heroTag: 'add',
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('New Card', style: TextStyle(color: Colors.white)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
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

        return Column(
          children: [
            Expanded(child: _buildCardsList()),
            InventoryPagination(cardProvider: cardProvider),
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search by Image functionality coming soon!')));
  }

  void _onScanBarcode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode scanning functionality coming soon!')));
  }

  void _onFilters(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters functionality coming soon!')));
  }
}

class InventoryCardItem extends StatelessWidget {
  final CardViewModel card;

  const InventoryCardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
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
    final imageFlex = context.isMobile ? 4 : 3;

    return Expanded(
      flex: imageFlex,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.defaultRadius))),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.defaultRadius)),
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
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final contentFlex = context.isMobile ? 2 : 2;
    final padding = context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding;

    return Expanded(
      flex: contentFlex,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildPriceText(context), _buildDiscountText(context), _buildStockText(context)],
        ),
      ),
    );
  }

  Widget _buildPriceText(BuildContext context) {
    final textStyle = context.isMobile ? ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold) : ResponsiveText.getTitle(context);

    return Text('₹${card.sellPrice}', style: textStyle);
  }

  Widget _buildDiscountText(BuildContext context) {
    return Text('-₹${card.maxDiscount}', style: ResponsiveText.getBody(context).copyWith(color: AppConfig.errorColor));
  }

  Widget _buildStockText(BuildContext context) {
    return Text('Stock: ${card.quantity}', style: ResponsiveText.getCaption(context));
  }
}

class InventoryPagination extends StatelessWidget {
  final CardListProvider cardProvider;

  const InventoryPagination({super.key, required this.cardProvider});

  @override
  Widget build(BuildContext context) {
    if (cardProvider.pagination == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cardProvider.pagination!.hasPrevious) ElevatedButton(onPressed: () => cardProvider.loadPreviousPage(), child: const Text('Previous')),
          const SizedBox(width: 16),
          Text('Page ${cardProvider.pagination?.currentPage ?? 1} of ${cardProvider.pagination?.totalPages ?? 1}'),
          const SizedBox(width: 16),
          if (cardProvider.hasMoreCards) ElevatedButton(onPressed: () => cardProvider.loadNextPage(), child: const Text('Next')),
        ],
      ),
    );
  }
}
