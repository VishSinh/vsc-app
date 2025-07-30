import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/shimmer_widgets.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/models/card_model.dart' as card_model;

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cardProvider = context.read<CardProvider>();
    await cardProvider.loadCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: 0,
      destinations: const [NavigationDestination(icon: Icon(Icons.inventory), label: 'Cards')],
      onDestinationSelected: (index) {},
      child: _buildCardsContent(),
    );
  }

  Widget _buildCardsContent() {
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
                child: PageHeader(
                  title: 'Cards Inventory',
                  actions: [
                    Consumer<PermissionProvider>(
                      builder: (context, permissionProvider, child) {
                        if (permissionProvider.canCreate('card')) {
                          return ActionButton(label: 'Add Card', icon: Icons.add, onPressed: () => context.go(RouteConstants.createCard));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SearchField(
            controller: _searchController,
            hintText: 'Search cards...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          SizedBox(height: AppConfig.largePadding),

          // Cards List
          Expanded(
            child: Consumer<CardProvider>(
              builder: (context, cardProvider, child) {
                if (cardProvider.isLoading && cardProvider.cards.isEmpty) {
                  return _buildShimmerSkeleton();
                }

                if (cardProvider.errorMessage != null) {
                  return CustomErrorWidget(message: cardProvider.errorMessage!, onRetry: () => cardProvider.refreshCards());
                }

                final filteredCards = cardProvider.getFilteredCards(_searchQuery);

                if (filteredCards.isEmpty) {
                  return EmptyStateWidget(
                    message: _searchQuery.isNotEmpty ? 'No cards found matching your search' : 'No cards found',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => cardProvider.refreshCards(),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1, // 3 columns on larger screens, 1 on mobile
                      // childAspectRatio: MediaQuery.of(context).size.width > 768 ? 0.7 : 0.5, // Better aspect ratios
                      crossAxisSpacing: AppConfig.defaultPadding,
                      mainAxisSpacing: AppConfig.defaultPadding,
                    ),
                    itemCount: filteredCards.length + (cardProvider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredCards.length) {
                        // Load more indicator
                        if (cardProvider.hasMoreData && !cardProvider.isLoading) {
                          cardProvider.loadMoreCards();
                        }
                        return cardProvider.isLoading
                            ? Padding(
                                padding: EdgeInsets.all(AppConfig.defaultPadding), // Changed from const to EdgeInsets
                                child: Center(
                                  child: SpinKitDoubleBounce(color: AppConfig.primaryColor, size: AppConfig.loadingIndicatorSize),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final card = filteredCards[index];
                      return _buildCardGridItem(card);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGridItem(card_model.Card card) {
    return Card(
      child: InkWell(
        onTap: () {
          print('🔍 CardsPage: Tapped card ID: ${card.id}');
          context.go('/cards/${card.id}');
        },
        child: Padding(
          padding: EdgeInsets.all(AppConfig.smallPadding), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Larger Image on the top
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
                child: card.image.isNotEmpty
                    ? Image.network(
                        card.image,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width > 768
                            ? MediaQuery.of(context).size.width *
                                  0.15 // Desktop/tablet
                            : MediaQuery.of(context).size.width * 0.4, // Mobile - much larger
                        fit: BoxFit.cover, // Changed to cover for better fill
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width > 768
                                ? MediaQuery.of(context).size.width * 0.15
                                : MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                            child: Icon(Icons.image, color: AppConfig.grey600),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width > 768
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                        child: Icon(Icons.image, color: AppConfig.grey600),
                      ),
              ),
              SizedBox(height: AppConfig.defaultPadding),

              // Status and Quantity badges
              Row(
                children: [
                  StatusBadge(text: card.isActive ? 'Active' : 'Inactive', isActive: card.isActive),
                  SizedBox(width: AppConfig.smallPadding),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppConfig.smallPadding, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusSmall),
                      border: Border.all(color: AppConfig.primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Qty: ${card.quantity}',
                      style: AppConfig.captionStyle.copyWith(color: AppConfig.primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConfig.smallPadding),

              // Barcode text (minimal info)
              Text(
                'Barcode: ${card.barcode}',
                style: AppConfig.bodyStyle.copyWith(fontWeight: FontWeight.w500, color: AppConfig.primaryColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppConfig.smallPadding),

              // Pricing (minimal info)
              Text('Price: \$${card.sellPrice}', style: AppConfig.bodyStyle.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerWrapper(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
                  ),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                        ),
                        SizedBox(height: AppConfig.smallPadding),
                        Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
