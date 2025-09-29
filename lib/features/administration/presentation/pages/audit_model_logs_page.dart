import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/administration/presentation/models/model_log_view_model.dart';
import 'package:vsc_app/features/administration/presentation/providers/audit_logs_provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/staff_provider.dart';

class AuditModelLogsPage extends StatelessWidget {
  const AuditModelLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuditLogsProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
      ],
      child: const _AuditModelLogsPageContent(),
    );
  }
}

class _AuditModelLogsPageContent extends StatefulWidget {
  const _AuditModelLogsPageContent();

  @override
  State<_AuditModelLogsPageContent> createState() => _AuditModelLogsPageContentState();
}

class _AuditModelLogsPageContentState extends State<_AuditModelLogsPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auditProvider = context.read<AuditLogsProvider>();
      auditProvider.setContext(context);
      auditProvider.fetchLogs(page: 1, pageSize: 50);

      final staffProvider = context.read<StaffProvider>();
      staffProvider.setContext(context);
      staffProvider.fetchStaff(pageSize: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuditLogsProvider, StaffProvider>(
      builder: (context, auditProvider, staffProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Model Logs'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: RefreshIndicator(
            onRefresh: () async => auditProvider.fetchLogs(page: 1, pageSize: 50),
            child: Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(auditProvider, staffProvider),
                  SizedBox(height: AppConfig.defaultPadding),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        context.isMobile ? _buildMobileList(auditProvider) : _buildDesktopTable(auditProvider),
                        if (auditProvider.pagination != null) Positioned(bottom: 10, child: _buildPagination(auditProvider)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(AuditLogsProvider auditProvider, StaffProvider staffProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Staff Filter
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Staff'),
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('All Staff')),
                  ...staffProvider.staff.map((s) => DropdownMenuItem<String>(value: s.id, child: Text(s.name))).toList(),
                ],
                value: auditProvider.selectedStaffId ?? '',
                onChanged: (value) => auditProvider.setStaffFilter(value?.isEmpty == true ? null : value),
              ),
            ),
          ),

          // Action Filter
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Action'),
                items: const [
                  DropdownMenuItem<String>(value: '', child: Text('All Actions')),
                  DropdownMenuItem<String>(value: 'CREATE', child: Text('CREATE')),
                  DropdownMenuItem<String>(value: 'UPDATE', child: Text('UPDATE')),
                  DropdownMenuItem<String>(value: 'DELETE', child: Text('DELETE')),
                ],
                value: auditProvider.selectedAction ?? '',
                onChanged: (value) => auditProvider.setActionFilter(value?.isEmpty == true ? null : value),
              ),
            ),
          ),

          // Start Date Filter
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Start Date'),
                controller: TextEditingController(
                  text: auditProvider.startDate != null ? DateFormatter.formatDate(auditProvider.startDate) : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: auditProvider.startDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    auditProvider.setDateRange(start: picked, end: auditProvider.endDate);
                  }
                },
              ),
            ),
          ),

          // End Date Filter
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'End Date'),
                controller: TextEditingController(
                  text: auditProvider.endDate != null ? DateFormatter.formatDate(auditProvider.endDate) : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: auditProvider.endDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    auditProvider.setDateRange(start: auditProvider.startDate, end: picked);
                  }
                },
              ),
            ),
          ),

          // Apply Button
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: OutlinedButton.icon(
                onPressed: () => auditProvider.fetchLogs(page: 1, pageSize: 50),
                icon: const Icon(Icons.filter_list),
                label: const Text('Apply'),
              ),
            ),
          ),

          // Clear Button
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  auditProvider.setStaffFilter(null);
                  auditProvider.setActionFilter(null);
                  auditProvider.setDateRange(start: null, end: null);
                  auditProvider.fetchLogs(page: 1, pageSize: 50);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(AuditLogsProvider provider) {
    final logs = provider.logs;
    if (provider.isLoading || provider.isPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logs.isEmpty) {
      return const Center(child: Text('No logs found'));
    }
    return ListView.builder(itemCount: logs.length, itemBuilder: (context, index) => _buildMobileItem(logs[index]));
  }

  Widget _buildMobileItem(ModelLogViewModel log) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
      child: ListTile(
        title: Text('${log.modelName} • ${log.action}', style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('By: ${log.staffName}'), Text('At: ${log.createdAt.toLocal()}')],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDetailsDialog(log),
      ),
    );
  }

  Widget _buildDesktopTable(AuditLogsProvider provider) {
    final logs = provider.logs;
    if (provider.isLoading || provider.isPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logs.isEmpty) {
      return const Center(child: Text('No logs found'));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300, width: 1)),
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
                        DataCell(Text(_formatDateTime(log.createdAt))),
                        DataCell(Text(log.staffName)),
                        DataCell(Text(log.modelName)),
                        DataCell(_buildActionText(log.action)),
                        DataCell(Text(log.modelId)),
                        DataCell(IconButton(icon: const Icon(Icons.visibility), onPressed: () => _showDetailsDialog(log))),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionText(String action) {
    Color color;
    switch (action.toUpperCase()) {
      case 'CREATE':
        color = Colors.green.shade700;
        break;
      case 'UPDATE':
        color = Colors.orange.shade700;
        break;
      case 'DELETE':
        color = Colors.red.shade700;
        break;
      default:
        color = Colors.grey.shade700;
    }
    return Text(
      action,
      style: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildPagination(AuditLogsProvider provider) {
    if (provider.pagination == null) return const SizedBox.shrink();

    final currentPage = provider.pagination?.currentPage ?? 1;
    final totalPages = provider.pagination?.totalPages ?? 1;
    final hasPrevious = provider.pagination!.hasPrevious;
    final hasNext = provider.pagination!.hasNext;

    return PaginationWidget(
      currentPage: currentPage,
      totalPages: totalPages,
      hasPrevious: hasPrevious,
      hasNext: hasNext,
      onPreviousPage: hasPrevious ? () => provider.loadPreviousPage() : null,
      onNextPage: hasNext ? () => provider.loadNextPage() : null,
    );
  }

  void _showDetailsDialog(ModelLogViewModel log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${log.modelName} • ${log.action}'),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By: ${log.staffName}'),
                  Text('At: ${_formatDateTime(log.createdAt)}'),
                  const SizedBox(height: 12),
                  const Text('New Values', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildKeyValueTable(log.newValues),
                  const SizedBox(height: 16),
                  const Text('Old Values', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildKeyValueTable(log.oldValues),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  Widget _buildKeyValueTable(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return const Text(
        '--',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300, width: 1)),
        dataRowMinHeight: 40,
        // Allow multi-line value cells for pretty JSON
        dataRowMaxHeight: double.infinity,
        columnSpacing: 16,
        columns: const [
          DataColumn(
            label: Text('Field', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: map.entries.map((e) {
          final valueObj = e.value;
          final String value = _formatAny(valueObj);
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          return DataRow(
            cells: [
              DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(
                SelectableText(
                  value,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700, fontFamily: 'monospace'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormatter.formatDateTime(dt.toLocal());
  }

  String _formatAny(dynamic value) {
    if (value == null) return 'null';
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }
}
