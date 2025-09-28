import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/staff_provider.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<StaffProvider>();
      provider.setContext(context);
      provider.fetchStaff(pageSize: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StaffProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Staff Management'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: AppConfig.defaultPadding),
                Expanded(child: context.isMobile ? _buildMobileStaffList() : _buildDesktopStaffTable()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAdmin = authProvider.hasRole(UserRole.admin);
        return Row(
          children: [
            const Text('Staff Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isAdmin)
              ButtonUtils.primaryButton(
                onPressed: () => context.push(RouteConstants.register),
                label: 'Register Staff',
                icon: Icons.person_add,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMobileStaffList() {
    return Consumer<StaffProvider>(
      builder: (context, provider, _) {
        final staff = provider.staff;
        return ListView.builder(
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final s = staff[index];
            return Card(
              margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
              child: ListTile(
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${s.phone}'),
                    Text('Role: ${s.role}'),
                    Text('Joined: ${DateFormatter.formatDate(DateFormatter.parseDateTime(s.dateJoined))}'),
                  ],
                ),
                trailing: Chip(
                  label: Text(s.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: s.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: s.isActive ? Colors.green : Colors.red),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopStaffTable() {
    return Consumer<StaffProvider>(
      builder: (context, provider, _) {
        final staff = provider.staff;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5), // Name
                1: FlexColumnWidth(1.5), // Phone
                2: FlexColumnWidth(1), // Role
                3: FlexColumnWidth(1), // Status
                4: FlexColumnWidth(1.5), // Joined
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  children: [
                    _buildTableCell('Name', isHeader: true),
                    _buildTableCell('Phone', isHeader: true),
                    _buildTableCell('Role', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                    _buildTableCell('Joined', isHeader: true),
                  ],
                ),
                // Data Rows
                ...staff.map(
                  (s) => TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    children: [
                      _buildTableCell(s.name),
                      _buildTableCell(s.phone),
                      _buildTableCell(s.role),
                      _buildTableCell(
                        '',
                        customWidget: Chip(
                          label: Text(s.isActive ? 'Active' : 'Inactive'),
                          backgroundColor: s.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: s.isActive ? Colors.green : Colors.red),
                        ),
                      ),
                      _buildTableCell(DateFormatter.formatDate(DateFormatter.parseDateTime(s.dateJoined))),
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

  Widget _buildTableCell(String text, {bool isHeader = false, Widget? customWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child:
          customWidget ??
          Text(
            text,
            style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: isHeader ? 14 : 13),
            textAlign: TextAlign.center,
          ),
    );
  }
}
