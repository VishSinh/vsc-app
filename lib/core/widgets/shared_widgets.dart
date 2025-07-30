import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

/// Standard loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({super.key, this.message, this.size = AppConfig.defaultLoadingSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(color: AppConfig.primaryColor, size: size),
          if (message != null) ...[
            SizedBox(height: AppConfig.defaultPadding),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Standard error widget
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({super.key, required this.message, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.error_outline, size: AppConfig.iconSizeXXLarge, color: AppConfig.errorColor),
          SizedBox(height: AppConfig.defaultPadding),
          Text(
            message,
            style: TextStyle(color: AppConfig.errorColor),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppConfig.defaultPadding),
            ButtonUtils.primaryButton(onPressed: onRetry, label: UITextConstants.retry),
          ],
        ],
      ),
    );
  }
}

/// Standard empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({super.key, required this.message, this.icon = Icons.inbox_outlined, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppConfig.iconSizeXXLarge, color: AppConfig.grey400),
          SizedBox(height: AppConfig.defaultPadding),
          Text(
            message,
            style: TextStyle(color: AppConfig.grey600),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: AppConfig.defaultPadding),
            ButtonUtils.primaryButton(onPressed: onAction, label: actionLabel!),
          ],
        ],
      ),
    );
  }
}

/// Standard search field
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchField({super.key, required this.controller, required this.hintText, this.onChanged, this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

/// Standard action button
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? SpinKitDoubleBounce(color: foregroundColor ?? AppConfig.primaryColor, size: AppConfig.loadingIndicatorSize) : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor, foregroundColor: foregroundColor),
    );
  }
}

/// Standard page header
class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? subtitle;

  const PageHeader({super.key, required this.title, this.actions, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ResponsiveText.getHeadline(context)),
                  if (subtitle != null) ...[SizedBox(height: AppConfig.smallPadding), subtitle!],
                ],
              ),
            ),
            if (actions != null) ...[SizedBox(width: AppConfig.defaultPadding), ...actions!],
          ],
        ),
        SizedBox(height: AppConfig.largePadding),
      ],
    );
  }
}

/// Standard list item card
class ListItemCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const ListItemCard({super.key, required this.leading, required this.title, this.subtitle, this.trailing, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.only(bottom: AppConfig.defaultPadding),
      child: ListTile(leading: leading, title: title, subtitle: subtitle, trailing: trailing, onTap: onTap),
    );
  }
}

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusBadge({super.key, required this.text, required this.isActive, this.activeColor, this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? AppConfig.successColor) : (inactiveColor ?? AppConfig.grey400);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.smallPadding, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
      child: Text(text, style: ResponsiveText.getCaption(context)),
    );
  }
}
