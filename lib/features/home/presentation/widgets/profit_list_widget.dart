import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_profit_view_model.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';

class ProfitListWidget extends StatelessWidget {
  final List<YearlyProfitViewModel> profitData;

  const ProfitListWidget({Key? key, required this.profitData}) : super(key: key);

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
    final totalProfit = provider.getTotalProfit();
    final highestProfitMonth = provider.getHighestProfitMonth();
    final lowestProfitMonth = provider.getLowestProfitMonth();

    final formattedTotalProfit = _formatCurrency(totalProfit);

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
                  _buildSummaryRow(context, 'Total Profit:', formattedTotalProfit, totalProfit >= 0 ? Colors.green : Colors.red),
                  if (highestProfitMonth != null) ...[
                    SizedBox(height: isMobile ? 6 : 8),
                    _buildSummaryRow(
                      context,
                      'Best Month:',
                      '${highestProfitMonth.formattedMonth} (${_formatCurrency(highestProfitMonth.profit)})',
                      Colors.green,
                    ),
                  ],
                  if (lowestProfitMonth != null) ...[
                    SizedBox(height: isMobile ? 6 : 8),
                    _buildSummaryRow(
                      context,
                      'Lowest Month:',
                      '${lowestProfitMonth.formattedMonth} (${_formatCurrency(lowestProfitMonth.profit)})',
                      lowestProfitMonth.profit < 0 ? Colors.red : Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // List of monthly profits
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: outerPadding),
            itemCount: profitData.length,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: isMobile ? 0.5 : 1),
            itemBuilder: (context, index) {
              final item = profitData[index];
              return ListTile(
                dense: isMobile,
                title: Text(item.formattedMonth, style: bodyStyle),
                trailing: Text(
                  _formatCurrency(item.profit),
                  style: bodyStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.profit > 0 ? Colors.green : (item.profit < 0 ? Colors.red : null),
                  ),
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
