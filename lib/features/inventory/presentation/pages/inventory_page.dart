import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shimmer_widgets.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/snackbar_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 0; // Will be set based on permissions
  final String _searchQuery = '';
  bool _showCardsList = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
        setState(() {
          _selectedIndex = index;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
    _initializePermissions();
    _setSelectedIndex();
  }

  Future<void> _loadCards() async {
    final cardProvider = context.read<CardProvider>();
    await cardProvider.loadCards();
  }

  void _initializePermissions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionProvider = context.read<PermissionProvider>();
      if (!permissionProvider.isInitialized) {
        setState(() {
          _isLoading = true;
        });

        permissionProvider
            .initializePermissions()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
      } else {
        setState(() {
          _isLoading = false;
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
    return ResponsiveLayout(
      selectedIndex: _selectedIndex,
      destinations: _getDestinations(),
      onDestinationSelected: _onDestinationSelected,
      pageTitle: UITextConstants.inventory,
      floatingActionButton: Consumer<PermissionProvider>(
        builder: (context, permissionProvider, child) {
          if (permissionProvider.canCreate('card')) {
            return FloatingActionButton(onPressed: () => context.go(RouteConstants.createCard), child: const Icon(Icons.add));
          }
          return const SizedBox.shrink();
        },
      ),
      child: _buildInventoryContent(),
    );
  }

  Widget _buildInventoryContent() {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(),
          // // Page Header
          // Text(UITextConstants.inventoryManagementTitle, style: ResponsiveText.getHeadline(context)),
          // SizedBox(height: AppConfig.smallPadding),

          // Quick Actions Section
          Row(),
          _buildQuickActions(),
          SizedBox(height: context.responsiveSpacing),

          // Cards List Section
          Expanded(child: _buildCardsListSection()),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
          runSpacing: context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding,
          children: [
            Consumer<PermissionProvider>(
              builder: (context, permissionProvider, child) {
                if (permissionProvider.canCreate('card')) {
                  return ButtonUtils.primaryButton(
                    onPressed: () => context.go(RouteConstants.createCard),
                    label: UITextConstants.addCards,
                    icon: Icons.add_card,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ButtonUtils.accentButton(
              onPressed: () {
                SnackbarUtils.showInfo(context, SnackbarConstants.getCardComingSoon);
              },
              label: UITextConstants.getCard,
              icon: Icons.search,
            ),
            ButtonUtils.secondaryButton(
              onPressed: () {
                SnackbarUtils.showInfo(context, SnackbarConstants.findSimilarCardComingSoon);
              },
              label: UITextConstants.findSimilarCard,
              icon: Icons.compare_arrows,
            ),
            ButtonUtils.warningButton(
              onPressed: () {
                setState(() {
                  _showCardsList = !_showCardsList;
                });
              },
              label: _showCardsList ? UITextConstants.hideTable : UITextConstants.viewInventory,
              icon: _showCardsList ? Icons.close : Icons.table_chart,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardsListSection() {
    if (!_showCardsList) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Consumer<CardProvider>(
              builder: (context, cardProvider, child) {
                return Text('Total ${cardProvider.getFilteredCards(_searchQuery).length} cards', style: ResponsiveText.getCaption(context));
              },
            ),
          ],
        ),
        // const SizedBox(height: AppConfig.defaultPadding),
        // _buildSearchField(),
        SizedBox(height: AppConfig.defaultPadding),
        Expanded(child: _isLoading ? _buildShimmerSkeleton() : _buildCardsList()),
      ],
    );
  }

  Widget _buildCardsList() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final filteredCards = cardProvider.getFilteredCards(_searchQuery);

        if (filteredCards.isEmpty) {
          return const EmptyStateWidget(message: 'No cards found', icon: Icons.inventory_2_outlined);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = context.gridCrossAxisCount;
            final childAspectRatio = context.gridChildAspectRatio;

            return GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: AppConfig.defaultPadding,
                mainAxisSpacing: AppConfig.defaultPadding,
              ),
              itemCount: filteredCards.length + (cardProvider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredCards.length) {
                  // Load more indicator
                  if (cardProvider.hasMoreData) {
                    _loadMoreCards(cardProvider);
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                }

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

  Widget _buildShimmerSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.gridCrossAxisCount;
        final childAspectRatio = context.gridChildAspectRatio;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppConfig.defaultPadding,
            mainAxisSpacing: AppConfig.defaultPadding,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return ShimmerWrapper(
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      flex: context.isMobile ? 4 : 3,
                      child: Container(width: double.infinity, color: Colors.white),
                    ),
                    Expanded(
                      flex: context.isMobile ? 2 : 2,
                      child: Padding(
                        padding: EdgeInsets.all(context.isMobile ? AppConfig.smallPadding : AppConfig.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: context.isMobile ? 6 : 8, width: 80),
                            SizedBox(height: context.isMobile ? 3 : 4, width: 60),
                            SizedBox(height: context.isMobile ? 3 : 4, width: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _loadMoreCards(CardProvider cardProvider) {
    if (!cardProvider.isLoading && cardProvider.hasMoreData) {
      cardProvider.loadMoreCards();
    }
  }
}
