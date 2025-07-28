import 'package:flutter/material.dart';
import 'package:vsc_app/core/utils/permission_manager.dart';

/// Widget that only shows if user has the specified permission
class PermissionWidget extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that only shows if user has any of the specified permissions
class AnyPermissionWidget extends StatelessWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const AnyPermissionWidget({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasAnyPermission(permissions)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that only shows if user has all of the specified permissions
class AllPermissionsWidget extends StatelessWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const AllPermissionsWidget({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasAllPermissions(permissions)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Button that only shows if user has the specified permission
class PermissionButton extends StatelessWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Widget? fallback;

  const PermissionButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.style,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Icon button that only shows if user has the specified permission
class PermissionIconButton extends StatelessWidget {
  final String permission;
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Widget? fallback;

  const PermissionIconButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      );
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// List tile that only shows if user has the specified permission
class PermissionListTile extends StatelessWidget {
  final String permission;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? fallback;

  const PermissionListTile({
    super.key,
    required this.permission,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      );
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Data row that only shows if user has the specified permission
class PermissionDataRow extends StatelessWidget {
  final String permission;
  final List<DataCell> cells;
  final Widget? fallback;

  const PermissionDataRow({
    super.key,
    required this.permission,
    required this.cells,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return DataRow(cells: cells);
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// Card that only shows if user has the specified permission
class PermissionCard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final Widget? fallback;

  const PermissionCard({
    super.key,
    required this.permission,
    required this.child,
    this.color,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.margin,
    this.clipBehavior,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionManager = PermissionManager();
    
    if (permissionManager.hasPermission(permission)) {
      return Card(
        color: color,
        shadowColor: shadowColor,
        elevation: elevation,
        shape: shape,
        margin: margin,
        clipBehavior: clipBehavior,
        child: child,
      );
    }
    
    return fallback ?? const SizedBox.shrink();
  }
} 