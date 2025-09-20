import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

/// Reusable header widget for auth forms
class AuthFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthFormHeader({super.key, required this.title, required this.subtitle, this.icon = Icons.inventory});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo/Icon
        Icon(icon, size: AppConfig.iconSizeXXLarge, color: AppConfig.primaryColor),
        SizedBox(height: AppConfig.defaultPadding),

        // Title
        Text(title, style: ResponsiveText.getHeadlineStyle(context), textAlign: TextAlign.center),
        SizedBox(height: AppConfig.smallPadding),

        // Subtitle
        Text(
          subtitle,
          style: ResponsiveText.getSubtitle(context).copyWith(color: AppConfig.grey600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsiveSpacing),
      ],
    );
  }
}
