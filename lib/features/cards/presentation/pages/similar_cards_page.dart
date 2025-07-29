import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/models/card_model.dart' as card_model;
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';

class SimilarCardsPage extends StatefulWidget {
  const SimilarCardsPage({super.key});

  @override
  State<SimilarCardsPage> createState() => _SimilarCardsPageState();
}

class _SimilarCardsPageState extends State<SimilarCardsPage> {
  List<card_model.Card> _similarCards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSimilarCards();
  }

  Future<void> _loadSimilarCards() async {
    final cardProvider = context.read<CardProvider>();
    final selectedImageUrl = cardProvider.selectedImageUrl;

    if (selectedImageUrl != null) {
      setState(() => _isLoading = true);
      final similarCards = await cardProvider.getSimilarCards(selectedImageUrl);
      setState(() {
        _similarCards = similarCards;
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseCard(card_model.Card card) async {
    final cardProvider = context.read<CardProvider>();

    // Show quantity dialog
    final quantity = await _showQuantityDialog();
    if (quantity != null) {
      final success = await cardProvider.purchaseCardStock(card.id, quantity);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully purchased $quantity units of ${card.barcode}'), backgroundColor: AppConfig.successColor),
          );
          context.go(RouteConstants.cards);
        }
      }
    }
  }

  Future<int?> _showQuantityDialog() async {
    int quantity = 1;
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the quantity to purchase:'),
            const SizedBox(height: AppConfig.defaultPadding),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 1;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(quantity), child: const Text('Purchase')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Cards'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.createCard)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _similarCards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: AppConfig.iconSizeLarge, color: AppConfig.grey400),
                  const SizedBox(height: AppConfig.defaultPadding),
                  Text('No similar cards found', style: AppConfig.headlineStyle.copyWith(color: AppConfig.grey400)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Similar Cards Found', style: AppConfig.headlineStyle),
                  const SizedBox(height: AppConfig.defaultPadding),
                  Text('${_similarCards.length} similar cards found. Select one to purchase stock:', style: AppConfig.bodyStyle),
                  const SizedBox(height: AppConfig.largePadding),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _similarCards.length,
                      itemBuilder: (context, index) {
                        final card = _similarCards[index];
                        return _buildSimilarCardItem(card);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSimilarCardItem(card_model.Card card) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppConfig.smallRadius),
          child: Image.network(
            card.image,
            width: AppConfig.iconSizeLarge,
            height: AppConfig.iconSizeLarge,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: AppConfig.iconSizeLarge,
              height: AppConfig.iconSizeLarge,
              color: AppConfig.grey300,
              child: Icon(Icons.image_not_supported, color: AppConfig.grey400),
            ),
          ),
        ),
        title: Text(card.barcode, style: AppConfig.titleStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor ID: ${card.vendorId}'),
            Text('Price: \$${card.sellPrice}'),
            Text('Quantity: ${card.quantity}'),
            Text('Status: ${card.isActive ? 'Active' : 'Inactive'}'),
          ],
        ),
        trailing: ElevatedButton(onPressed: () => _purchaseCard(card), child: const Text('Purchase')),
      ),
    );
  }
}
