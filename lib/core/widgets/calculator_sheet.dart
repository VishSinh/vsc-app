import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({super.key});

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
            child: const FractionallySizedBox(heightFactor: 0.8, child: CalculatorSheet()),
          ),
        );
      },
    );
  }

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  double _value = 0;
  String _expression = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              children: [
                const Text('Calculator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).maybePop()),
              ],
            ),
          ),
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
          const Divider(height: 1),
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
                  displayStyle: const TextStyle(fontSize: 1),
                  operatorColor: colorScheme.surfaceVariant,
                  operatorStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
                  commandColor: colorScheme.surfaceVariant,
                  commandStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                  numColor: colorScheme.surfaceVariant,
                  numStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
