import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/pages/inventory_page.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';

class OutOfStockCardsPage extends StatefulWidget {
  const OutOfStockCardsPage({super.key});

  @override
  State<OutOfStockCardsPage> createState() => _OutOfStockCardsPageState();
}

class _OutOfStockCardsPageState extends State<OutOfStockCardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.getOutOfStockCards();
    });
  }

  @override
  void dispose() {
    context.read<AnalyticsProvider>().clearContext();
    super.dispose();
  }

  GridConfig _calculateGridConfig(double availableWidth) {
    const cardWidth = 240.0; // Fixed card width for desktop
    const mobileCardWidth = 160.0; // Fixed card width for mobile
    const childAspectRatio = 0.9;

    final effectiveCardWidth = context.isDesktop ? cardWidth : mobileCardWidth;
    final crossAxisCount = (availableWidth / (effectiveCardWidth + AppConfig.defaultPadding)).floor();
    final maxCrossAxisCount = context.isDesktop ? 6 : 2;
    final actualCrossAxisCount = crossAxisCount.clamp(1, maxCrossAxisCount);

    return GridConfig(crossAxisCount: actualCrossAxisCount, childAspectRatio: childAspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Out of Stock Cards')),
      body: ChangeNotifierProvider(
        create: (context) => CardDetailProvider(),
        child: Consumer<AnalyticsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading out of stock cards...');
            }

            if (provider.errorMessage != null) {
              return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.getOutOfStockCards());
            }

            final cards = provider.outOfStockCards ?? [];
            if (cards.isEmpty) {
              return const EmptyStateWidget(message: 'No out of stock cards found', icon: Icons.inventory_2_outlined);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final gridConfig = _calculateGridConfig(constraints.maxWidth);

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridConfig.crossAxisCount,
                    childAspectRatio: gridConfig.childAspectRatio,
                    crossAxisSpacing: AppConfig.defaultPadding,
                    mainAxisSpacing: AppConfig.defaultPadding,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return InventoryCardItem(card: cards[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
