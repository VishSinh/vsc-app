import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/features/auth/presentation/providers/auth_provider.dart';

class AdministrationPage extends StatefulWidget {
  const AdministrationPage({super.key});

  @override
  State<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 4; // Administration tab
  late TabController _tabController;
  String _searchQuery = '';

  // Mock admin data
  final List<Map<String, dynamic>> _staff = [
    {
      'id': 'STAFF-001',
      'name': 'John Admin',
      'email': 'john@company.com',
      'role': UserRole.admin,
      'status': 'Active',
      'lastLogin': '2024-01-15 10:30',
    },
    {
      'id': 'STAFF-002',
      'name': 'Sarah Manager',
      'email': 'sarah@company.com',
      'role': UserRole.manager,
      'status': 'Active',
      'lastLogin': '2024-01-15 09:15',
    },
  ];

  final List<Map<String, dynamic>> _partners = [
    {
      'id': 'PARTNER-001',
      'name': 'Premium Paper Co.',
      'type': 'Vendor',
      'contact': 'Mike Johnson',
      'email': 'mike@premiumpaper.com',
      'status': 'Active',
    },
    {
      'id': 'PARTNER-002',
      'name': 'Quality Print Supplies',
      'type': 'Vendor',
      'contact': 'Lisa Chen',
      'email': 'lisa@qualityprint.com',
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> _auditLogs = [
    {
      'id': 'AUDIT-001',
      'action': 'Order Created',
      'user': 'John Admin',
      'timestamp': '2024-01-15 14:30',
      'details': 'Created order ORD-001 for John Doe',
      'ip': '192.168.1.100',
    },
    {
      'id': 'AUDIT-002',
      'action': 'Stock Updated',
      'user': 'Sarah Manager',
      'timestamp': '2024-01-15 13:45',
      'details': 'Updated stock for CARD-001: +500 units',
      'ip': '192.168.1.101',
    },
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    const NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Orders'),
    const NavigationDestination(icon: Icon(Icons.inventory), label: 'Inventory'),
    const NavigationDestination(icon: Icon(Icons.print), label: 'Production'),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Administration'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/inventory');
        break;
      case 3:
        context.go('/production');
        break;
      case 4:
        break; // Already on administration
    }
  }

  List<Map<String, dynamic>> get _filteredStaff {
    return _staff.where((staff) {
      return staff['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPartners {
    return _partners.where((partner) {
      return partner['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          partner['contact'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredAuditLogs {
    return _auditLogs.where((log) {
      return log['action'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log['user'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onDestinationSelected: _onDestinationSelected,
      child: _buildAdministrationContent(),
    );
  }

  Widget _buildAdministrationContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAdmin = authProvider.hasRole(UserRole.admin);

        return Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Administration', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (isAdmin)
                    ElevatedButton.icon(
                      onPressed: () => context.go('/register'),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register Staff'),
                    ),
                ],
              ),
              const SizedBox(height: AppConfig.largePadding),
              _buildFilters(),
              const SizedBox(height: AppConfig.defaultPadding),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Staff (${_filteredStaff.length})'),
                        Tab(text: 'Partners (${_filteredPartners.length})'),
                        Tab(text: 'Audit Logs (${_filteredAuditLogs.length})'),
                      ],
                    ),
                    const SizedBox(height: AppConfig.defaultPadding),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [_buildStaffList(), _buildPartnersList(), _buildAuditLogsList()]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return TextField(
      decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search)),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildStaffList() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < AppConfig.mobileBreakpoint ? _buildMobileStaffList() : _buildDesktopStaffTable();
  }

  Widget _buildMobileStaffList() {
    return ListView.builder(
      itemCount: _filteredStaff.length,
      itemBuilder: (context, index) {
        final staff = _filteredStaff[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(staff['email']), Text('Role: ${staff['role'].value}'), Text('Last login: ${staff['lastLogin']}')],
            ),
            trailing: Chip(
              label: Text(staff['status']),
              backgroundColor: staff['status'] == 'Active' ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
              labelStyle: TextStyle(color: staff['status'] == 'Active' ? AppConfig.successColor : AppConfig.errorColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopStaffTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Staff ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Last Login')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredStaff.map((staff) {
          return DataRow(
            cells: [
              DataCell(Text(staff['id'])),
              DataCell(Text(staff['name'])),
              DataCell(Text(staff['email'])),
              DataCell(Text(staff['role'].value)),
              DataCell(
                Chip(
                  label: Text(staff['status']),
                  backgroundColor: staff['status'] == 'Active' ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: staff['status'] == 'Active' ? AppConfig.successColor : AppConfig.errorColor),
                ),
              ),
              DataCell(Text(staff['lastLogin'])),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit staff
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View staff details
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

  Widget _buildPartnersList() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < AppConfig.mobileBreakpoint ? _buildMobilePartnersList() : _buildDesktopPartnersTable();
  }

  Widget _buildMobilePartnersList() {
    return ListView.builder(
      itemCount: _filteredPartners.length,
      itemBuilder: (context, index) {
        final partner = _filteredPartners[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(partner['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('${partner['type']} • ${partner['contact']}'), Text(partner['email'])],
            ),
            trailing: Chip(
              label: Text(partner['status']),
              backgroundColor: partner['status'] == 'Active' ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
              labelStyle: TextStyle(color: partner['status'] == 'Active' ? AppConfig.successColor : AppConfig.errorColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopPartnersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Partner ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Contact')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredPartners.map((partner) {
          return DataRow(
            cells: [
              DataCell(Text(partner['id'])),
              DataCell(Text(partner['name'])),
              DataCell(Text(partner['type'])),
              DataCell(Text(partner['contact'])),
              DataCell(Text(partner['email'])),
              DataCell(
                Chip(
                  label: Text(partner['status']),
                  backgroundColor: partner['status'] == 'Active' ? AppConfig.successColor.withOpacity(0.1) : AppConfig.errorColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: partner['status'] == 'Active' ? AppConfig.successColor : AppConfig.errorColor),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit partner
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View partner details
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

  Widget _buildAuditLogsList() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < AppConfig.mobileBreakpoint ? _buildMobileAuditLogsList() : _buildDesktopAuditLogsTable();
  }

  Widget _buildMobileAuditLogsList() {
    return ListView.builder(
      itemCount: _filteredAuditLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredAuditLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(log['action'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('${log['user']} • ${log['timestamp']}'), Text(log['details']), Text('IP: ${log['ip']}')],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopAuditLogsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Log ID')),
          DataColumn(label: Text('Action')),
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Timestamp')),
          DataColumn(label: Text('Details')),
          DataColumn(label: Text('IP Address')),
        ],
        rows: _filteredAuditLogs.map((log) {
          return DataRow(
            cells: [
              DataCell(Text(log['id'])),
              DataCell(Text(log['action'])),
              DataCell(Text(log['user'])),
              DataCell(Text(log['timestamp'])),
              DataCell(Text(log['details'])),
              DataCell(Text(log['ip'])),
            ],
          );
        }).toList(),
      ),
    );
  }
}
