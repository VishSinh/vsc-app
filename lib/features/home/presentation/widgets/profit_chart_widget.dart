import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_profit_view_model.dart';

class ProfitChartWidget extends StatelessWidget {
  final List<YearlyProfitViewModel> profitData;

  const ProfitChartWidget({Key? key, required this.profitData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate max profit for chart scaling
    final maxProfit = profitData.fold<double>(0, (max, item) => item.profit > max ? item.profit : max);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Profit Trend', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Financial year overview', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxProfit * 1.2, // Add 20% padding to the top
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = profitData[groupIndex];
                      return BarTooltipItem(
                        '${item.formattedMonth}\n${item.formattedProfit}',
                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Show abbreviated month names
                        if (value.toInt() >= 0 && value.toInt() < profitData.length) {
                          final month = profitData[value.toInt()].formattedMonth.split(' ')[0];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              month,
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Format currency values on Y-axis
                        return Text(
                          '₹${value.toInt()}',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: profitData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  // Determine bar color based on profit value
                  Color barColor = theme.colorScheme.primary;
                  if (item.profit > 0) {
                    barColor = Colors.green;
                  } else if (item.profit < 0) {
                    barColor = Colors.red;
                  }

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.profit,
                        color: barColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
