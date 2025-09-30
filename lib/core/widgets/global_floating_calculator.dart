import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';

import 'package:vsc_app/core/services/calculator_service.dart';

/// A global floating calculator launcher using DraggableFloatWidget.
class GlobalFloatingCalculator extends StatelessWidget {
  const GlobalFloatingCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableFloatWidget(
      width: 56,
      height: 56,
      config: DraggableFloatWidgetBaseConfig(
        isFullScreen: true,
        initPositionXInLeft: false,
        initPositionYInTop: false,
        initPositionYMarginBorder: 100,
        borderLeft: 0,
        borderRight: 0,
        borderTop: 0,
        borderBottom: 24,
        exposedPartWidthWhenHidden: 16,
        borderTopContainTopBar: true,
        animDuration: const Duration(milliseconds: 250),
      ),
      onTap: () async {
        await CalculatorService.toggle();
      },
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        elevation: 6,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              await CalculatorService.toggle();
            },
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Center(child: Icon(Icons.calculate_outlined, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
