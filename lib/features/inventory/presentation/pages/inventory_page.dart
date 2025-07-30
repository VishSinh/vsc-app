import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
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
import 'package:vsc_app/core/models/card_model.dart' as card_model;

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 2; // Inventory tab
  String _searchQuery = '';
  bool _showCardsList = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard),
    const NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders),
    const NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory),
    const NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go(RouteConstants.dashboard);
        break;
      case 1:
        context.go(RouteConstants.orders);
        break;
      case 2:
        break; // Already on inventory
      case 3:
        context.go(RouteConstants.production);
        break;
      case 4:
        context.go(RouteConstants.administration);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
    _initializePermissions();
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
      destinations: _destinations,
      onDestinationSelected: _onDestinationSelected,
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
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(),
          // Page Header
          Text(UITextConstants.inventoryManagementTitle, style: ResponsiveText.getHeadline(context)),
          SizedBox(height: AppConfig.smallPadding),

          // Quick Actions Section
          _buildQuickActions(),
          SizedBox(height: AppConfig.largePadding),

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
          spacing: AppConfig.defaultPadding,
          runSpacing: AppConfig.defaultPadding,
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
            final crossAxisCount = constraints.maxWidth < AppConfig.mobileBreakpoint ? 2 : 3;
            final childAspectRatio = constraints.maxWidth < AppConfig.mobileBreakpoint ? 1.2 : 0.8;

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

  Widget _buildCardItem(card_model.Card card) {
    return Card(
      child: InkWell(
        onTap: () => context.go('${RouteConstants.cardDetail}/${card.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppConfig.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.barcode, style: ResponsiveText.getTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: AppConfig.smallPadding),
                    Text('Price: \$${card.sellPrice}', style: ResponsiveText.getBody(context)),
                    Text('Stock: ${card.quantity}', style: ResponsiveText.getBody(context)),
                    Row(
                      children: [
                        Icon(
                          card.isActive ? Icons.check_circle : Icons.cancel,
                          size: AppConfig.iconSizeSmall,
                          color: card.isActive ? AppConfig.successColor : AppConfig.errorColor,
                        ),
                        SizedBox(width: AppConfig.smallPadding),
                        Text(
                          card.isActive ? 'Active' : 'Inactive',
                          style: ResponsiveText.getCaption(context).copyWith(color: card.isActive ? AppConfig.successColor : AppConfig.errorColor),
                        ),
                      ],
                    ),
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
        final crossAxisCount = constraints.maxWidth < AppConfig.mobileBreakpoint ? 1 : 3;
        final childAspectRatio = constraints.maxWidth < AppConfig.mobileBreakpoint ? 1.2 : 0.8;

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
                      flex: 3,
                      child: Container(width: double.infinity, color: Colors.white),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(AppConfig.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8, width: 100),
                            SizedBox(height: 4, width: 80),
                            SizedBox(height: 4, width: 60),
                            SizedBox(height: 4, width: 40),
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
