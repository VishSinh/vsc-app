import 'package:flutter/material.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

/// Widget to display a similar card in a tile format
class SimilarCardTile extends StatelessWidget {
  final CardViewModel card;
  final VoidCallback? onSelect;
  final bool isSelected;

  const SimilarCardTile({super.key, required this.card, this.onSelect, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: context.responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with similarity score
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Similarity: ${card.formattedSimilarity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                ],
              ),
              SizedBox(height: context.responsiveSpacing),

              // Card image
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    card.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 32),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing),

              // Card details
              _buildDetailRow('Barcode', card.barcode),
              _buildDetailRow('Sell Price', card.formattedSellPrice),
              _buildDetailRow('Cost Price', card.formattedCostPrice),
              _buildDetailRow('Quantity', card.formattedQuantity),
              _buildDetailRow('Profit Margin', card.formattedProfitMargin),
              _buildDetailRow('Total Value', card.formattedTotalValue),

              SizedBox(height: context.responsiveSpacing),

              // Select button
              SizedBox(
                width: double.infinity,
                child: ButtonUtils.primaryButton(
                  onPressed: onSelect,
                  label: isSelected ? 'Selected' : 'Select This Card',
                  icon: isSelected ? Icons.check : Icons.check_circle_outline,
                  isLoading: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
