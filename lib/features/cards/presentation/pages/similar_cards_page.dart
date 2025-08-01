import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

class SimilarCardsPage extends StatefulWidget {
  const SimilarCardsPage({super.key});

  @override
  State<SimilarCardsPage> createState() => _SimilarCardsPageState();
}

class _SimilarCardsPageState extends State<SimilarCardsPage> {
  List<CardViewModel> _similarCards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSimilarCards();
  }

  Future<void> _loadSimilarCards() async {
    final cardProvider = context.read<CardProvider>();

    // Use the similar cards from provider
    setState(() => _isLoading = true);
    setState(() {
      _similarCards = cardProvider.similarCards;
      _isLoading = false;
    });
  }

  Future<void> _purchaseCard(CardViewModel card) async {
    final cardProvider = context.read<CardProvider>();

    // Show quantity dialog
    final quantity = await _showQuantityDialog();
    if (quantity != null) {
      // TODO: Implement purchase functionality
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Successfully purchased $quantity units of ${card.barcode}'), backgroundColor: AppConfig.successColor));
        context.go(RouteConstants.inventory);
      }
    }
  }

  Future<int?> _showQuantityDialog() async {
    int quantity = 1;
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the quantity to purchase:'),
            SizedBox(height: AppConfig.defaultPadding),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 1;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
          ButtonUtils.primaryButton(onPressed: () => Navigator.of(context).pop(quantity), label: 'Purchase'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Similar Cards'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.createCard)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _similarCards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: AppConfig.iconSizeLarge, color: AppConfig.grey400),
                  SizedBox(height: AppConfig.defaultPadding),
                  Text('No similar cards found', style: ResponsiveText.getHeadline(context).copyWith(color: AppConfig.grey400)),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Similar Cards Found', style: ResponsiveText.getHeadline(context)),
                  SizedBox(height: AppConfig.defaultPadding),
                  Text('${_similarCards.length} similar cards found. Select one to purchase stock:', style: ResponsiveText.getBody(context)),
                  SizedBox(height: AppConfig.largePadding),
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

  Widget _buildSimilarCardItem(CardViewModel card) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.defaultPadding),
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
        title: Text(card.barcode, style: ResponsiveText.getTitle(context)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor ID: ${card.vendorId}'),
            Text('Price: ₹${card.sellPrice}'),
            Text('Quantity: ${card.quantity}'),
            Text('Max Discount: ${card.maxDiscount}%'),
            Text('Similarity: ${card.formattedSimilarity}'),
          ],
        ),
        trailing: ButtonUtils.primaryButton(onPressed: () => _purchaseCard(card), label: 'Purchase'),
      ),
    );
  }
}
