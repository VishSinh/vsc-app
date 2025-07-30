import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vsc_app/app/app_config.dart';

/// Shimmer skeleton for card items
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            // Title skeleton
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
            SizedBox(height: AppConfig.smallPadding),
            // Subtitle skeleton
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for list items
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
        ),
        title: Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
        ),
        subtitle: Container(
          width: 150,
          height: 12,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
        ),
        trailing: Container(
          width: 60,
          height: 24,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for table rows
class TableRowSkeleton extends StatelessWidget {
  const TableRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          Expanded(
            flex: 1,
            child: Container(
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          Expanded(
            flex: 1,
            child: Container(
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          Expanded(
            flex: 1,
            child: Container(
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for dashboard stats
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                ),
                const Spacer(),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
            SizedBox(height: AppConfig.smallPadding),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
            SizedBox(height: AppConfig.smallPadding),
            Container(
              width: 150,
              height: 12,
              decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that applies shimmer effect to child widgets
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerWrapper({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(baseColor: AppConfig.shimmerBaseColor, highlightColor: AppConfig.shimmerHighlightColor, child: child);
  }
}

/// Shimmer skeleton for form fields
class FormFieldSkeleton extends StatelessWidget {
  const FormFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
        ),
        SizedBox(height: AppConfig.smallPadding),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(color: AppConfig.shimmerBaseColor, borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
        ),
      ],
    );
  }
}
