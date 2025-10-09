import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/route_constants.dart';

/// Utility functions for image-related operations
class ImageUtils {
  /// Shows an enlarged image dialog with zoom and pan capabilities
  static void showEnlargedImageDialog(BuildContext context, String imageUrl, {String? cardId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                if (cardId != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteConstants.cardDetail.replaceFirst(':id', cardId));
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
