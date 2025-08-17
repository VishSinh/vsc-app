import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';

/// A reusable pagination widget with a modern, compact design.
///
/// This widget displays pagination controls with previous/next buttons and
/// current page indicator. It's designed to float over content with a
/// semi-transparent dark background.
class PaginationWidget extends StatelessWidget {
  /// Current page number
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Whether there's a previous page available
  final bool hasPrevious;

  /// Whether there's a next page available
  final bool hasNext;

  /// Callback when previous button is pressed
  final VoidCallback? onPreviousPage;

  /// Callback when next button is pressed
  final VoidCallback? onNextPage;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    this.onPreviousPage,
    this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: AppConfig.secondaryColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(context: context, icon: Icons.chevron_left, onPressed: hasPrevious ? onPreviousPage : null),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$currentPage / $totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          _buildPaginationButton(context: context, icon: Icons.chevron_right, onPressed: hasNext ? onNextPage : null),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({required BuildContext context, required IconData icon, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          foregroundColor: onPressed != null ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
