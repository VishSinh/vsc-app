import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/job_status.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'All';

  // Mock production data
  final List<Map<String, dynamic>> _printingJobs = [
    {
      'id': 'PRINT-001',
      'orderId': 'ORD-001',
      'customer': 'John Doe',
      'type': 'Business Cards',
      'quantity': 1000,
      'status': JobStatus.pending,
      'assignedTo': 'Printer-01',
      'dueDate': '2024-01-20',
    },
    {
      'id': 'PRINT-002',
      'orderId': 'ORD-002',
      'customer': 'Jane Smith',
      'type': 'Flyers',
      'quantity': 500,
      'status': JobStatus.inProgress,
      'assignedTo': 'Printer-02',
      'dueDate': '2024-01-18',
    },
  ];

  final List<Map<String, dynamic>> _boxOrders = [
    {
      'id': 'BOX-001',
      'orderId': 'ORD-001',
      'customer': 'John Doe',
      'type': 'Cardboard Box',
      'quantity': 5,
      'status': JobStatus.completed,
      'assignedTo': 'BoxMaker-01',
      'dueDate': '2024-01-19',
    },
  ];

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

  List<Map<String, dynamic>> get _filteredPrintingJobs {
    return _printingJobs.where((job) {
      final matchesSearch =
          job['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || job['status'].value == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredBoxOrders {
    return _boxOrders.where((job) {
      final matchesSearch =
          job['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || job['status'].value == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, child) {
        return _buildProductionContent();
      },
    );
  }

  Widget _buildProductionContent() {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(UITextConstants.production, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          // SizedBox(height: AppConfig.largePadding),
          _buildFilters(),
          SizedBox(height: AppConfig.defaultPadding),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Printing Jobs (${_filteredPrintingJobs.length})'),
                    Tab(text: 'Box Orders (${_filteredBoxOrders.length})'),
                  ],
                ),
                SizedBox(height: AppConfig.defaultPadding),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildJobsList(_filteredPrintingJobs, 'Printing'), _buildJobsList(_filteredBoxOrders, 'Box')],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search jobs...', prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _statusFilter,
            decoration: const InputDecoration(labelText: 'Status'),
            items: ['All', ...JobStatus.values.map((s) => s.value)].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _statusFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList(List<Map<String, dynamic>> jobs, String type) {
    return context.isMobile ? _buildMobileJobsList(jobs, type) : _buildDesktopJobsTable(jobs, type);
  }

  Widget _buildMobileJobsList(List<Map<String, dynamic>> jobs, String type) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(job['id'], style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${job['customer']} • ${job['type']}', style: ResponsiveText.getBody(context)),
                Text('Qty: ${job['quantity']} • Due: ${job['dueDate']}', style: ResponsiveText.getCaption(context)),
                if (job['assignedTo'] != null) Text('Assigned to: ${job['assignedTo']}', style: ResponsiveText.getCaption(context)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(job['status'].value),
                  backgroundColor: _getStatusColor(job['status']).withOpacity(0.1),
                  labelStyle: TextStyle(color: _getStatusColor(job['status'])),
                ),
                const SizedBox(height: AppConfig.spacingTiny),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit job status
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopJobsTable(List<Map<String, dynamic>> jobs, String type) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Job ID')),
          const DataColumn(label: Text('Order ID')),
          const DataColumn(label: Text('Customer')),
          const DataColumn(label: Text('Type')),
          const DataColumn(label: Text('Quantity')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Assigned To')),
          const DataColumn(label: Text('Due Date')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: jobs.map((job) {
          return DataRow(
            cells: [
              DataCell(Text(job['id'], style: ResponsiveText.getBody(context))),
              DataCell(Text(job['orderId'], style: ResponsiveText.getBody(context))),
              DataCell(Text(job['customer'], style: ResponsiveText.getBody(context))),
              DataCell(Text(job['type'], style: ResponsiveText.getBody(context))),
              DataCell(Text(job['quantity'].toString(), style: ResponsiveText.getBody(context))),
              DataCell(
                Chip(
                  label: Text(job['status'].value),
                  backgroundColor: _getStatusColor(job['status']).withOpacity(0.1),
                  labelStyle: TextStyle(color: _getStatusColor(job['status'])),
                ),
              ),
              DataCell(Text(job['assignedTo'] ?? 'Unassigned', style: ResponsiveText.getBody(context))),
              DataCell(Text(job['dueDate'], style: ResponsiveText.getBody(context))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit job status
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View job details
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return AppConfig.warningColor;
      case JobStatus.inProgress:
        return AppConfig.accentColor;
      case JobStatus.completed:
        return AppConfig.successColor;
      case JobStatus.failed:
        return AppConfig.errorColor;
      case JobStatus.cancelled:
        return AppConfig.grey400;
    }
  }
}
