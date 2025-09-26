import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/administration/presentation/models/model_log_view_model.dart';
import 'package:vsc_app/features/administration/presentation/providers/audit_logs_provider.dart';

class AuditModelLogsPage extends StatefulWidget {
  const AuditModelLogsPage({super.key});

  @override
  State<AuditModelLogsPage> createState() => _AuditModelLogsPageState();
}

class _AuditModelLogsPageState extends State<AuditModelLogsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AuditLogsProvider>();
      provider.setContext(context);
      provider.fetchLogs(page: 1, pageSize: 10);
    });
  }

  List<ModelLogViewModel> get _filteredLogs {
    final provider = context.read<AuditLogsProvider>();
    var logs = provider.logs;

    if (provider.searchQuery.isNotEmpty) {
      final q = provider.searchQuery.toLowerCase();
      logs = logs
          .where(
            (l) =>
                l.id.toLowerCase().contains(q) ||
                l.staffName.toLowerCase().contains(q) ||
                l.modelName.toLowerCase().contains(q) ||
                l.action.toLowerCase().contains(q),
          )
          .toList();
    }

    return logs;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditLogsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Model Logs'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(provider),
                SizedBox(height: AppConfig.defaultPadding),
                _buildSearch(provider),
                SizedBox(height: AppConfig.defaultPadding),
                Expanded(child: context.isMobile ? _buildMobileList(provider) : _buildDesktopTable(provider)),
                SizedBox(height: AppConfig.defaultPadding),
                _buildPagination(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuditLogsProvider provider) {
    return Row(
      children: [
        Text('Model Logs', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.fetchLogs(page: 1, pageSize: 10)),
      ],
    );
  }

  Widget _buildSearch(AuditLogsProvider provider) {
    return TextField(
      decoration: const InputDecoration(hintText: 'Search by staff, model, action...', prefixIcon: Icon(Icons.search)),
      onChanged: provider.setSearchQuery,
    );
  }

  Widget _buildMobileList(AuditLogsProvider provider) {
    final logs = _filteredLogs;
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
    final logs = _filteredLogs;
    if (provider.isLoading || provider.isPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logs.isEmpty) {
      return const Center(child: Text('No logs found'));
    }

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
                    DataCell(Text(_formatDateTime(log.createdAt))),
                    DataCell(Text(log.staffName)),
                    DataCell(Text(log.modelName)),
                    DataCell(_buildActionChip(log.action)),
                    DataCell(Text(log.modelId)),
                    DataCell(IconButton(icon: const Icon(Icons.visibility), onPressed: () => _showDetailsDialog(log))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionChip(String action) {
    Color color;
    switch (action.toUpperCase()) {
      case 'CREATE':
        color = Colors.green;
        break;
      case 'UPDATE':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(action),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildPagination(AuditLogsProvider provider) {
    final pagination = provider.pagination;
    if (pagination == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page ${pagination.currentPage} of ${pagination.totalPages}'),
        SizedBox(width: AppConfig.defaultPadding),
        IconButton(onPressed: pagination.hasPrevious ? provider.loadPreviousPage : null, icon: const Icon(Icons.chevron_left)),
        IconButton(onPressed: pagination.hasNext ? provider.loadNextPage : null, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  void _showDetailsDialog(ModelLogViewModel log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${log.modelName} • ${log.action}'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By: ${log.staffName}'),
                  Text('At: ${_formatDateTime(log.createdAt)}'),
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
        );
      },
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

  String _formatDateTime(DateTime dt) {
    return dt.toLocal().toString().replaceFirst('.000', '');
  }
}
