import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';

/// Reusable image display widget with error handling
class ImageDisplay extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const ImageDisplay({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(AppConfig.smallRadius);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;
    final effectiveFallbackColor = fallbackColor ?? AppConfig.grey600;

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: effectiveBorderRadius),
            child: Icon(fallbackIcon, color: effectiveFallbackColor, size: _getIconSize()),
          );
        },
      ),
    );
  }

  double _getIconSize() {
    // Scale icon size based on image dimensions
    final minDimension = width < height ? width : height;
    if (minDimension <= AppConfig.imageSizeSmall) return AppConfig.iconSizeSmall;
    if (minDimension <= AppConfig.imageSizeMedium) return AppConfig.iconSizeMedium;
    if (minDimension <= AppConfig.imageSizeLarge) return AppConfig.iconSizeLarge;
    return AppConfig.iconSizeXLarge;
  }
}
