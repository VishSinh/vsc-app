import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';

class AdministrationPage extends StatelessWidget {
  const AdministrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, child) {
        return _buildAdministrationContent(context);
      },
    );
  }

  Widget _buildAdministrationContent(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.extent(
                    maxCrossAxisExtent: context.isMobile ? 220 : 280,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: context.isMobile ? 1.6 : 2.6,
                    children: [
                      _buildRegisterStaffCard(context),
                      _buildStaffManagementCard(context),
                      _buildModelLogsCard(context),
                      _buildApiLogsCard(context),
                      _buildCustomersCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterStaffCard(BuildContext context) {
    return _buildAdminCard(
      context: context,
      title: 'Register Staff',
      description: 'Add new staff members to the system',
      icon: Icons.person_add,
      color: Colors.blue,
      onTap: () => context.push(RouteConstants.register),
    );
  }

  Widget _buildStaffManagementCard(BuildContext context) {
    return _buildAdminCard(
      context: context,
      title: 'Staff Management',
      description: 'View and manage all staff members',
      icon: Icons.people,
      color: Colors.green,
      onTap: () => context.push(RouteConstants.staffManagement),
    );
  }

  Widget _buildModelLogsCard(BuildContext context) {
    return _buildAdminCard(
      context: context,
      title: 'Model Logs',
      description: 'Monitor system activities and changes',
      icon: Icons.history,
      color: Colors.orange,
      onTap: () => context.push(RouteConstants.auditModelLogs),
    );
  }

  Widget _buildApiLogsCard(BuildContext context) {
    return _buildAdminCard(
      context: context,
      title: 'API Logs',
      description: 'Inspect API requests and responses',
      icon: Icons.api,
      color: Colors.purple,
      onTap: () => context.push(RouteConstants.auditApiLogs),
    );
  }

  Widget _buildCustomersCard(BuildContext context) {
    return _buildAdminCard(
      context: context,
      title: 'Customers',
      description: 'View all customers with pagination',
      icon: Icons.people_alt,
      color: Colors.teal,
      onTap: () => context.push(RouteConstants.customers),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
