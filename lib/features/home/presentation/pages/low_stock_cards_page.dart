import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/pages/inventory_page.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';

class LowStockCardsPage extends StatefulWidget {
  const LowStockCardsPage({super.key});

  @override
  State<LowStockCardsPage> createState() => _LowStockCardsPageState();
}

class _LowStockCardsPageState extends State<LowStockCardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.getLowStockCards();
    });
  }

  @override
  void dispose() {
    context.read<AnalyticsProvider>().clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Cards')),
      body: ChangeNotifierProvider(
        create: (context) => CardDetailProvider(),
        child: Consumer<AnalyticsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading low stock cards...');
            }

            if (provider.errorMessage != null) {
              return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.getLowStockCards());
            }

            final cards = provider.lowStockCards ?? [];
            if (cards.isEmpty) {
              return const EmptyStateWidget(message: 'No low stock cards found', icon: Icons.inventory_2_outlined);
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return InventoryCardItem(card: cards[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
