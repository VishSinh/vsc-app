import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';

/// Reusable customer info card widget
class CustomerInfoCard extends StatelessWidget {
  final Customer? customer;
  final String title;
  final bool showEmptyState;

  const CustomerInfoCard({super.key, this.customer, this.title = 'Customer', this.showEmptyState = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: ResponsiveText.getTitle(context)),
            const SizedBox(height: AppConfig.smallPadding),
            if (customer != null) ...[
              Text('Name: ${customer!.name}'),
              Text('Phone: ${customer!.phone}'),
            ] else if (showEmptyState) ...[
              Text('No customer selected', style: ResponsiveText.getBody(context).copyWith(color: AppConfig.grey400)),
            ],
          ],
        ),
      ),
    );
  }
}
