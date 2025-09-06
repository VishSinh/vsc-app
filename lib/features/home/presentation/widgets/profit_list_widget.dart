import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_profit_view_model.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';

class ProfitListWidget extends StatelessWidget {
  final List<YearlyProfitViewModel> profitData;

  const ProfitListWidget({Key? key, required this.profitData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);

    // Get data from provider
    final totalProfit = provider.getTotalProfit();
    final highestProfitMonth = provider.getHighestProfitMonth();
    final lowestProfitMonth = provider.getLowestProfitMonth();

    final formattedTotalProfit = totalProfit.toStringAsFixed(2);

    return Column(
      children: [
        // Summary card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yearly Summary', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildSummaryRow(context, 'Total Profit:', '₹$formattedTotalProfit', totalProfit >= 0 ? Colors.green : Colors.red),
                  if (highestProfitMonth != null) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Best Month:',
                      '${highestProfitMonth.formattedMonth} (${highestProfitMonth.formattedProfit})',
                      Colors.green,
                    ),
                  ],
                  if (lowestProfitMonth != null) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Lowest Month:',
                      '${lowestProfitMonth.formattedMonth} (${lowestProfitMonth.formattedProfit})',
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
            itemCount: profitData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = profitData[index];
              return ListTile(
                title: Text(item.formattedMonth),
                trailing: Text(
                  item.formattedProfit,
                  style: TextStyle(fontWeight: FontWeight.bold, color: item.profit > 0 ? Colors.green : (item.profit < 0 ? Colors.red : null)),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
