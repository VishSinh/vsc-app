import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_sale_view_model.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';

class SaleListWidget extends StatelessWidget {
  final List<YearlySaleViewModel> saleData;

  const SaleListWidget({Key? key, required this.saleData}) : super(key: key);

  /// Format large numbers for display
  String _formatCurrency(double value) {
    final absValue = value.abs();

    if (absValue >= 1000000000) {
      // Billions
      return '₹${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (absValue >= 1000000) {
      // Millions
      return '₹${(value / 1000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000) {
      // Thousands
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else {
      // Regular numbers
      return '₹${value.toInt()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;

    // Get data from provider
    final totalSale = provider.getTotalSale();
    final highestSaleMonth = provider.getHighestSaleMonth();
    final lowestSaleMonth = provider.getLowestSaleMonth();

    final formattedTotalSale = _formatCurrency(totalSale);

    // Responsive values
    final outerPadding = isMobile ? 12.0 : (isDesktop ? 20.0 : 16.0);
    final innerPadding = isMobile ? 12.0 : (isDesktop ? 20.0 : 16.0);
    final spacing = isMobile ? 8.0 : 16.0;
    final titleStyle = isMobile ? theme.textTheme.titleSmall : theme.textTheme.titleMedium;
    final bodyStyle = isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge;

    return Column(
      children: [
        // Summary card
        Padding(
          padding: EdgeInsets.all(outerPadding),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yearly Summary', style: titleStyle),
                  SizedBox(height: spacing),
                  _buildSummaryRow(context, 'Total Sale:', formattedTotalSale, Colors.blue),
                  if (highestSaleMonth != null) ...[
                    SizedBox(height: isMobile ? 6 : 8),
                    _buildSummaryRow(
                      context,
                      'Best Month:',
                      '${highestSaleMonth.formattedMonth} (${_formatCurrency(highestSaleMonth.sale)})',
                      Colors.blue,
                    ),
                  ],
                  if (lowestSaleMonth != null) ...[
                    SizedBox(height: isMobile ? 6 : 8),
                    _buildSummaryRow(
                      context,
                      'Lowest Month:',
                      '${lowestSaleMonth.formattedMonth} (${_formatCurrency(lowestSaleMonth.sale)})',
                      lowestSaleMonth.sale == 0 ? Colors.grey : Colors.blue.shade300,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // List of monthly sales
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: outerPadding),
            itemCount: saleData.length,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: isMobile ? 0.5 : 1),
            itemBuilder: (context, index) {
              final item = saleData[index];
              return ListTile(
                dense: isMobile,
                title: Text(item.formattedMonth, style: bodyStyle),
                trailing: Text(
                  _formatCurrency(item.sale),
                  style: bodyStyle?.copyWith(fontWeight: FontWeight.bold, color: item.sale > 0 ? Colors.blue : Colors.grey),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    final textStyle = isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: textStyle)),
        Text(
          value,
          style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
