import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();

  void _onDestinationSelected(int index) {
    final cardProvider = context.read<CardProvider>();
    cardProvider.setSelectedIndex(index);

    final destinations = _getDestinations();
    final route = NavigationItems.getRouteForIndex(index, destinations);
    if (route != '/inventory') {
      context.go(route);
    }
  }

  List<NavigationDestination> _getDestinations() {
    final permissionProvider = context.read<PermissionProvider>();
    return NavigationItems.getDestinationsForPermissions(
      canManageOrders: permissionProvider.canManageOrders,
      canManageInventory: permissionProvider.canManageInventory,
      canManageProduction: permissionProvider.canManageProduction,
      canManageVendors: permissionProvider.canManageVendors,
      canManageSystem: permissionProvider.canManageSystem,
      canViewAuditLogs: permissionProvider.canViewAuditLogs,
    );
  }

  void _setSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final destinations = _getDestinations();
        final index = NavigationItems.getSelectedIndexForPage('inventory', destinations);
        final cardProvider = context.read<CardProvider>();
        cardProvider.setSelectedIndex(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardProvider = context.read<CardProvider>();
      if (mounted && cardProvider.cards.isEmpty) {
        _loadCards();
      }
    });

    _initializePermissions();
    _setSelectedIndex();
  }

  void _loadCards() {
    final cardProvider = context.read<CardProvider>();
    cardProvider.setContext(context);
    cardProvider.loadCards();
  }

  void _initializePermissions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionProvider = context.read<PermissionProvider>();
      if (!permissionProvider.isInitialized) {
        permissionProvider.initializePermissions().catchError((error) {
          // Handle error if needed
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        return ResponsiveLayout(
          selectedIndex: cardProvider.selectedIndex,
          destinations: _getDestinations(),
          onDestinationSelected: _onDestinationSelected,
          pageTitle: UITextConstants.inventory,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () => _loadCards(),
                backgroundColor: Colors.orange,
                heroTag: 'reload',
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Refresh', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Consumer<PermissionProvider>(
                builder: (context, permissionProvider, child) {
                  if (permissionProvider.canCreate('card')) {
                    return FloatingActionButton.extended(
                      onPressed: () => context.go(RouteConstants.createCard),
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
          child: _buildInventoryContent(),
        );
      },
    );
  }

  Widget _buildInventoryContent() {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards List Section
          Expanded(child: _buildCardsListSection()),
        ],
      ),
    );
  }

  Widget _buildCardsListSection() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (cardProvider.isLoading) {
          return const LoadingWidget(message: 'Loading cards...');
        }

        return Column(
          children: [
            Expanded(child: _buildCardsList()),
            _buildPagination(cardProvider),
          ],
        );
      },
    );
  }

  Widget _buildCardsList() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final filteredCards = cardProvider.getFilteredCards(cardProvider.searchQuery);

        if (filteredCards.isEmpty) {
          return const EmptyStateWidget(message: 'No cards found', icon: Icons.inventory_2_outlined);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive grid parameters to maintain consistent card sizes
            final availableWidth = constraints.maxWidth;
            final cardWidth = context.isDesktop ? 280.0 : 160.0; // Fixed card width
            final crossAxisCount = (availableWidth / (cardWidth + AppConfig.defaultPadding)).floor();
            final actualCrossAxisCount = crossAxisCount.clamp(1, context.isDesktop ? 6 : 2); // Max 6 on desktop, 2 on mobile
            final childAspectRatio = 0.8; // Fixed aspect ratio for consistent card proportions

            return GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: actualCrossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: AppConfig.defaultPadding,
                mainAxisSpacing: AppConfig.defaultPadding,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];
                return _buildCardItem(card);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardItem(CardViewModel card) {
    return Card(
      child: InkWell(
        onTap: () => context.goNamed(RouteConstants.cardDetailRouteName, pathParameters: {'id': card.id}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - more prominent, especially on mobile
            Expanded(
              flex: context.isMobile ? 4 : 3, // Much more space for image on mobile
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
            ),
            // Content section - more compact and image-focused
            Expanded(
              flex: context.isMobile ? 2 : 2, // Reduced content space to give more to image
              child: Padding(
                padding: EdgeInsets.all(context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Price and Stock - compact layout
                    Text(
                      '₹${card.sellPrice}',
                      style: context.isMobile
                          ? ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)
                          : ResponsiveText.getTitle(context),
                    ),
                    Text('-₹${card.maxDiscount}', style: ResponsiveText.getBody(context).copyWith(color: AppConfig.errorColor)),
                    Text(
                      'Stock: ${card.quantity}',
                      style: context.isMobile ? ResponsiveText.getCaption(context) : ResponsiveText.getCaption(context),
                    ),
                    // Max Discount - compact display
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(CardProvider cardProvider) {
    if (cardProvider.pagination == null) return const SizedBox.shrink();

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
