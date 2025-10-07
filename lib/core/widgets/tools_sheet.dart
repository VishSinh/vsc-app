import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ToolsSheet extends StatefulWidget {
  const ToolsSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: const FractionallySizedBox(heightFactor: 0.8, child: ToolsSheet()),
          ),
        );
      },
    );
  }

  @override
  State<ToolsSheet> createState() => _ToolsSheetState();
}

class _ToolsSheetState extends State<ToolsSheet> {
  double _value = 0;
  String _expression = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, size: 34), onPressed: () => Navigator.of(context).maybePop()),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: TabBar(
                labelStyle: TextStyle(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Calculator'),
                  Tab(text: 'Calendar'),
                ],
              ),
            ),

            Expanded(child: TabBarView(children: [_buildCalculator(context, colorScheme), _buildCalendar(context)])),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _expression,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SimpleCalculator(
              value: _value,
              hideExpression: true,
              onChanged: (key, val, exp) {
                setState(() {
                  final newVal = val is num ? (val as num).toDouble() : _value;
                  _value = newVal;
                  _expression = exp ?? '';
                });
              },
              onTappedDisplay: (val, exp) {
                Navigator.of(context).pop(val.toString());
              },
              theme: CalculatorThemeData(
                displayColor: Colors.transparent,
                displayStyle: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                operatorColor: colorScheme.surfaceVariant,
                operatorStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 24, fontWeight: FontWeight.w600),
                commandColor: colorScheme.surfaceVariant,
                commandStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 24, fontWeight: FontWeight.w600),
                numColor: colorScheme.surfaceVariant,
                numStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 24, fontWeight: FontWeight.w600),

                borderColor: Colors.transparent,
                borderWidth: 4,
                expressionColor: Colors.transparent,
                expressionStyle: const TextStyle(fontSize: 1),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(_value.toString()),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Use result'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SfCalendar(
        view: CalendarView.month,
        showDatePickerButton: true,
        monthViewSettings: const MonthViewSettings(showAgenda: false),
        monthCellBuilder: (BuildContext context, MonthCellDetails details) => _buildMonthCell(context, details),
      ),
    );
  }

  Widget _buildMonthCell(BuildContext context, MonthCellDetails details) {
    final date = details.date;
    final visibleDates = details.visibleDates;
    final middleDate = visibleDates[visibleDates.length ~/ 2];
    final bool isInCurrentMonth = date.month == middleDate.month && date.year == middleDate.year;
    final bool isSunday = date.weekday == DateTime.sunday;
    final now = DateTime.now();
    final bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    final baseColor = isInCurrentMonth
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
    Color textColor = isSunday ? Colors.red : baseColor;
    if (!isInCurrentMonth && isSunday) {
      textColor = Colors.red.withOpacity(0.5);
    }

    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isToday)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary),
            ),
          Text(
            '${date.day}',
            style: TextStyle(
              color: isToday ? Theme.of(context).colorScheme.onPrimary : textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Removed holiday appointment dot
        ],
      ),
    );
  }
}
