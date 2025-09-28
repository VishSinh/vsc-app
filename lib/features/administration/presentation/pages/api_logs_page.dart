import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/administration/presentation/models/api_log_view_model.dart';
import 'package:vsc_app/features/administration/presentation/providers/api_logs_provider.dart';
import 'package:vsc_app/features/administration/presentation/providers/staff_provider.dart';

class ApiLogsPage extends StatelessWidget {
  const ApiLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiLogsProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
      ],
      child: const _ApiLogsPageContent(),
    );
  }
}

class _ApiLogsPageContent extends StatefulWidget {
  const _ApiLogsPageContent();

  @override
  State<_ApiLogsPageContent> createState() => _ApiLogsPageContentState();
}

class _ApiLogsPageContentState extends State<_ApiLogsPageContent> {
  final TextEditingController _endpointController = TextEditingController();
  final TextEditingController _statusCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final apiProvider = context.read<ApiLogsProvider>();
      apiProvider.setContext(context);
      apiProvider.fetchLogs(page: 1, pageSize: 50);

      final staffProvider = context.read<StaffProvider>();
      staffProvider.setContext(context);
      staffProvider.fetchStaff(pageSize: 50);

      // Initialize controllers from provider values
      _endpointController.text = apiProvider.endpoint ?? '';
      _statusCodeController.text = apiProvider.statusCode?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _statusCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApiLogsProvider, StaffProvider>(
      builder: (context, apiProvider, staffProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('API Logs'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: RefreshIndicator(
            onRefresh: () async => apiProvider.fetchLogs(page: 1, pageSize: 50),
            child: Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(apiProvider, staffProvider),
                  SizedBox(height: AppConfig.defaultPadding),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        context.isMobile ? _buildMobileList(apiProvider) : _buildDesktopTable(apiProvider),
                        if (apiProvider.pagination != null) Positioned(bottom: 10, child: _buildPagination(apiProvider)),
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

  Widget _buildFilters(ApiLogsProvider apiProvider, StaffProvider staffProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Staff'),
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('All Staff')),
                  ...staffProvider.staff.map((s) => DropdownMenuItem<String>(value: s.id, child: Text(s.name))).toList(),
                ],
                value: apiProvider.selectedStaffId ?? '',
                onChanged: (value) => apiProvider.setStaffFilter(value?.isEmpty == true ? null : value),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Start DateTime'),
                controller: TextEditingController(
                  text: apiProvider.startDate != null ? DateFormatter.formatDateTime(apiProvider.startDate!.toLocal()) : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: apiProvider.startDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    apiProvider.setDateRange(start: picked, end: apiProvider.endDate);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'End DateTime'),
                controller: TextEditingController(
                  text: apiProvider.endDate != null ? DateFormatter.formatDateTime(apiProvider.endDate!.toLocal()) : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: apiProvider.endDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    apiProvider.setDateRange(start: apiProvider.startDate, end: picked);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Endpoint contains'),
                controller: _endpointController,
                onChanged: (v) => apiProvider.setEndpoint(v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 160,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Status Code'),
                keyboardType: TextInputType.number,
                controller: _statusCodeController,
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  apiProvider.setStatusCode(parsed);
                },
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => apiProvider.fetchLogs(page: 1, pageSize: 50),
              icon: const Icon(Icons.filter_list),
              label: const Text('Apply'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                apiProvider.setStaffFilter(null);
                apiProvider.setDateRange(start: null, end: null);
                apiProvider.setEndpoint(null);
                apiProvider.setStatusCode(null);
                _endpointController.text = '';
                _statusCodeController.text = '';
                FocusScope.of(context).unfocus();
                apiProvider.fetchLogs(page: 1, pageSize: 50);
                setState(() {});
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(ApiLogsProvider provider) {
    final logs = provider.logs;
    if (provider.isLoading || provider.isPageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logs.isEmpty) {
      return const Center(child: Text('No logs found'));
    }
    return ListView.builder(itemCount: logs.length, itemBuilder: (context, index) => _buildMobileItem(logs[index]));
  }

  Widget _buildMobileItem(ApiLogViewModel log) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
      child: ListTile(
        title: Text(
          '${log.requestMethod} ${log.endpoint}',
          style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('By: ${log.staffName}'), Text('At: ${_formatDateTime(log.createdAt)}')],
        ),
        trailing: _buildStatusText(log.statusCode),
        onTap: () => _showDetailsDialog(log),
      ),
    );
  }

  Widget _buildDesktopTable(ApiLogsProvider provider) {
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
                DataColumn(label: Text('Endpoint')),
                DataColumn(label: Text('Method')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Duration (ms)')),
                DataColumn(label: Text('Details')),
              ],
              rows: logs
                  .map(
                    (log) => DataRow(
                      cells: [
                        DataCell(Text(_formatDateTime(log.createdAt))),
                        DataCell(Text(log.staffName)),
                        DataCell(Text(log.endpoint)),
                        DataCell(Text(log.requestMethod)),
                        DataCell(_buildStatusText(log.statusCode)),
                        DataCell(Text('${log.durationMs}')),
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

  Widget _buildStatusText(int statusCode) {
    Color color;
    if (statusCode >= 200 && statusCode < 300) {
      color = Colors.green.shade700;
    } else if (statusCode >= 400 && statusCode < 500) {
      color = Colors.orange.shade700;
    } else if (statusCode >= 500) {
      color = Colors.red.shade700;
    } else {
      color = Colors.grey.shade700;
    }
    return Text(
      '$statusCode',
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildPagination(ApiLogsProvider provider) {
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

  void _showDetailsDialog(ApiLogViewModel log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${log.requestMethod} ${log.endpoint} • ${log.statusCode}'),
          content: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By: ${log.staffName}'),
                  Text('At: ${_formatDateTime(log.createdAt)}'),
                  const SizedBox(height: 12),
                  const Text('Request Body', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildJsonPreview(log.requestBody),
                  const SizedBox(height: 16),
                  const Text('Response Body', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildJsonPreview(log.responseBody),
                  const SizedBox(height: 16),
                  const Text('Headers', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildKeyValueTable(log.headers.map((k, v) => MapEntry(k, v.toString()))),
                  const SizedBox(height: 16),
                  const Text('Query Params', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildKeyValueTable(log.queryParams.map((k, v) => MapEntry(k, v.toString()))),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  Widget _buildJsonPreview(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const Text(
        '--',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final encoder = const JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(json);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        formatted,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildKeyValueTable(Map<String, String> map) {
    if (map.isEmpty) {
      return const Text(
        '--',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300, width: 1)),
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        columnSpacing: 16,
        columns: const [
          DataColumn(
            label: Text('Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: map.entries
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(e.value, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormatter.formatDateTime(dt.toLocal());
  }
}
