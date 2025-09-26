import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/staff_provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/audit_logs_provider.dart';
import 'package:vsc_app/features/administration/presentation/models/model_log_view_model.dart';

class AdministrationPage extends StatefulWidget {
  const AdministrationPage({super.key});

  @override
  State<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initializedLoad = false;
  String _staffSearch = '';
  String _logSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ModelLogViewModel> _filterLogs(List<ModelLogViewModel> logs) {
    if (_logSearch.isEmpty) return logs;
    final q = _logSearch.toLowerCase();
    return logs
        .where(
          (l) =>
              l.staffName.toLowerCase().contains(q) ||
              l.modelName.toLowerCase().contains(q) ||
              l.action.toLowerCase().contains(q) ||
              l.modelId.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, child) {
        return _buildAdministrationContent();
      },
    );
  }

  Widget _buildAdministrationContent() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => AuditLogsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final isAdmin = authProvider.hasRole(UserRole.admin);

          if (!_initializedLoad) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final sp = context.read<StaffProvider>();
              sp.setContext(context);
              sp.fetchStaff(pageSize: 50);

              final ap = context.read<AuditLogsProvider>();
              ap.setContext(context);
              ap.fetchLogs(pageSize: 50);
            });
            _initializedLoad = true;
          }

          final staffCount = context.watch<StaffProvider>().staff.length;
          final logCount = context.watch<AuditLogsProvider>().logs.length;

          return Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(UITextConstants.administration, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (isAdmin)
                      Row(
                        children: [
                          ButtonUtils.primaryButton(
                            onPressed: () => context.push(RouteConstants.register),
                            label: UITextConstants.registerStaff,
                            icon: Icons.person_add,
                          ),
                          SizedBox(width: AppConfig.smallPadding),
                          ButtonUtils.secondaryButton(
                            onPressed: () => context.push(RouteConstants.auditModelLogs),
                            label: 'Model Logs',
                            icon: Icons.history,
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: AppConfig.largePadding),
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: 'Staff ($staffCount)'),
                          Tab(text: 'Model Logs ($logCount)'),
                        ],
                      ),
                      SizedBox(height: AppConfig.defaultPadding),
                      Expanded(
                        child: TabBarView(controller: _tabController, children: [_buildStaffTab(), _buildModelLogsTab()]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaffTab() {
    return Consumer<StaffProvider>(
      builder: (context, staffProvider, _) {
        final filtered = staffProvider.staff.where((s) {
          if (_staffSearch.isEmpty) return true;
          final q = _staffSearch.toLowerCase();
          return s.name.toLowerCase().contains(q) || s.phone.toLowerCase().contains(q) || s.role.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search staff by name, phone, role...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _staffSearch = v),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Expanded(child: context.isMobile ? _buildMobileStaffList(filtered) : _buildDesktopStaffTable(filtered)),
          ],
        );
      },
    );
  }

  Widget _buildMobileStaffList(List<dynamic> staffList) {
    return ListView.builder(
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final s = staffList[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(s.name, style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Phone: ${s.phone}'), Text('Role: ${s.role}'), Text('Joined: ${s.dateJoined}')],
            ),
            trailing: Chip(
              label: Text(s.isActive ? 'Active' : 'Inactive'),
              backgroundColor: s.isActive ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
              labelStyle: TextStyle(color: s.isActive ? AppConfig.successColor : AppConfig.errorColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopStaffTable(List<dynamic> staffList) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Joined')),
          ],
          rows: staffList
              .map(
                (s) => DataRow(
                  cells: [
                    DataCell(Text(s.id)),
                    DataCell(Text(s.name)),
                    DataCell(Text(s.phone)),
                    DataCell(Text(s.role)),
                    DataCell(
                      Chip(
                        label: Text(s.isActive ? 'Active' : 'Inactive'),
                        backgroundColor: s.isActive ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: s.isActive ? AppConfig.successColor : AppConfig.errorColor),
                      ),
                    ),
                    DataCell(Text(s.dateJoined)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildModelLogsTab() {
    return Consumer2<AuditLogsProvider, StaffProvider>(
      builder: (context, logsProvider, staffProvider, _) {
        final logs = _filterLogs(logsProvider.logs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModelLogFilters(logsProvider, staffProvider),
            SizedBox(height: AppConfig.defaultPadding),
            Expanded(child: context.isMobile ? _buildMobileAuditLogsList(logs) : _buildDesktopAuditLogsTable(logs)),
          ],
        );
      },
    );
  }

  Widget _buildModelLogFilters(AuditLogsProvider provider, StaffProvider staffProvider) {
    final actions = const ['CREATE', 'UPDATE', 'DELETE'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Staff'),
              items: [
                const DropdownMenuItem<String>(value: '', child: Text('All Staff')),
                ...staffProvider.staff.map((s) => DropdownMenuItem<String>(value: s.id, child: Text(s.name))).toList(),
              ],
              value: provider.selectedStaffId ?? '',
              onChanged: (v) => provider.setStaffFilter((v ?? '').isEmpty ? null : v),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Action'),
              items: [
                const DropdownMenuItem<String>(value: '', child: Text('All Actions')),
                ...actions.map((a) => DropdownMenuItem<String>(value: a, child: Text(a))).toList(),
              ],
              value: provider.selectedAction ?? '',
              onChanged: (v) => provider.setActionFilter((v ?? '').isEmpty ? null : v),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          SizedBox(
            width: 180,
            child: TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Start'),
              controller: TextEditingController(text: provider.startDate?.toLocal().toString().split('.').first ?? ''),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: provider.startDate ?? DateTime.now(),
                );
                if (picked != null) provider.setDateRange(start: picked, end: provider.endDate);
              },
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          SizedBox(
            width: 180,
            child: TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'End'),
              controller: TextEditingController(text: provider.endDate?.toLocal().toString().split('.').first ?? ''),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: provider.endDate ?? DateTime.now(),
                );
                if (picked != null) provider.setDateRange(start: provider.startDate, end: picked);
              },
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(hintText: 'Search by staff, model, action...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _logSearch = v),
            ),
          ),
          SizedBox(width: AppConfig.defaultPadding),
          ButtonUtils.primaryButton(onPressed: () => provider.fetchLogs(page: 1, pageSize: 50), label: 'Apply', icon: Icons.filter_list),
          SizedBox(width: AppConfig.smallPadding),
          ButtonUtils.secondaryButton(
            onPressed: () {
              provider.setStaffFilter(null);
              provider.setActionFilter(null);
              provider.setDateRange(start: null, end: null);
              setState(() => _logSearch = '');
              provider.fetchLogs(page: 1, pageSize: 50);
            },
            label: 'Reset',
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAuditLogsList(List<ModelLogViewModel> logs) {
    if (logs.isEmpty) return const Center(child: Text('No logs found'));
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text('${log.modelName} • ${log.action}', style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('By: ${log.staffName}'), Text('At: ${log.createdAt.toLocal()}')],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLogDetails(log),
          ),
        );
      },
    );
  }

  Widget _buildDesktopAuditLogsTable(List<ModelLogViewModel> logs) {
    if (logs.isEmpty) return const Center(child: Text('No logs found'));
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Staff')),
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Model ID')),
            DataColumn(label: Text('Details')),
          ],
          rows: logs
              .map(
                (log) => DataRow(
                  cells: [
                    DataCell(Text(log.createdAt.toLocal().toString().split('.').first)),
                    DataCell(Text(log.staffName)),
                    DataCell(Text(log.modelName)),
                    DataCell(Chip(label: Text(log.action), backgroundColor: Colors.grey.withOpacity(0.1))),
                    DataCell(Text(log.modelId)),
                    DataCell(IconButton(icon: const Icon(Icons.visibility), onPressed: () => _showLogDetails(log))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLogDetails(ModelLogViewModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.modelName} • ${log.action}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By: ${log.staffName}'),
                Text('At: ${log.createdAt.toLocal().toString().split('.').first}'),
                const SizedBox(height: 12),
                const Text('New Values', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildKeyValueList(log.newValues),
                const SizedBox(height: 12),
                const Text('Old Values', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildKeyValueList(log.oldValues),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildKeyValueList(Map<String, dynamic> map) {
    if (map.isEmpty) return const Text('--');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: map.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(e.key, style: const TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${e.value}')),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
