import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

/// Reusable desktop info row widget for order items
class DesktopInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTotal;

  const DesktopInfoRow({super.key, required this.label, required this.value, required this.icon, required this.color, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConfig.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.smallRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: ResponsiveText.getCaption(context).copyWith(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: ResponsiveText.getBody(context).copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
