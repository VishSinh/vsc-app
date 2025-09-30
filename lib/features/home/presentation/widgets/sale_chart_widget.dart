import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_sale_view_model.dart';

class SaleChartWidget extends StatelessWidget {
  final List<YearlySaleViewModel> saleData;

  const SaleChartWidget({Key? key, required this.saleData}) : super(key: key);

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
    final isDesktop = context.isDesktop;
    final isMobile = context.isMobile;

    // Calculate max sale for chart scaling
    final maxSale = saleData.fold<double>(0, (max, item) => item.sale > max ? item.sale : max);

    // Responsive values
    final padding = isMobile ? 12.0 : (isDesktop ? 24.0 : 16.0);
    final titleStyle = isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge;
    final subtitleStyle = isMobile
        ? theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))
        : theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6));
    final axisFontSize = isMobile ? 10.0 : 12.0;
    final barWidth = isMobile ? 12.0 : (isDesktop ? 20.0 : 16.0);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Sale Trend', style: titleStyle),
          SizedBox(height: isMobile ? 4 : 8),
          Text('Financial year overview', style: subtitleStyle),
          SizedBox(height: isMobile ? 16 : 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSale * 1.2, // Add 20% padding to the top
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surface,
                    tooltipPadding: EdgeInsets.all(isMobile ? 6 : 8),
                    tooltipMargin: isMobile ? 4 : 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = saleData[groupIndex];
                      return BarTooltipItem(
                        '${item.formattedMonth}\n${_formatCurrency(item.sale)}',
                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14),
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
                        if (value.toInt() >= 0 && value.toInt() < saleData.length) {
                          final month = saleData[value.toInt()].formattedMonth.split(' ')[0];
                          return Padding(
                            padding: EdgeInsets.only(top: isMobile ? 4 : 8),
                            child: Text(
                              month,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: axisFontSize,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: isMobile ? 24 : 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Format currency values on Y-axis with abbreviations
                        return Text(
                          _formatCurrency(value),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: axisFontSize,
                          ),
                        );
                      },
                      reservedSize: isMobile ? 45 : 50,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: saleData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  // Determine bar color based on sale value
                  Color barColor = theme.colorScheme.primary;
                  if (item.sale > 0) {
                    barColor = Colors.blue;
                  }

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.sale,
                        color: barColor,
                        width: barWidth,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMobile ? 2 : 4),
                          topRight: Radius.circular(isMobile ? 2 : 4),
                        ),
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
