import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 2; // Inventory tab
  String _searchQuery = '';
  String _categoryFilter = 'All';

  // Mock inventory data
  final List<Map<String, dynamic>> _inventory = [
    {
      'id': 'CARD-001',
      'name': 'Business Card Premium',
      'category': 'Business Cards',
      'stock': 1500,
      'minStock': 100,
      'price': 0.15,
      'vendor': 'Premium Paper Co.',
    },
    {
      'id': 'CARD-002',
      'name': 'Flyer Glossy A4',
      'category': 'Flyers',
      'stock': 500,
      'minStock': 200,
      'price': 0.25,
      'vendor': 'Quality Print Supplies',
    },
    {
      'id': 'CARD-003',
      'name': 'Brochure Tri-Fold',
      'category': 'Brochures',
      'stock': 75,
      'minStock': 50,
      'price': 0.45,
      'vendor': 'Premium Paper Co.',
    },
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    const NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Orders'),
    const NavigationDestination(icon: Icon(Icons.inventory), label: 'Inventory'),
    const NavigationDestination(icon: Icon(Icons.print), label: 'Production'),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Administration'),
  ];

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
        break; // Already on inventory
      case 3:
        context.go('/production');
        break;
      case 4:
        context.go('/administration');
        break;
    }
  }

  List<Map<String, dynamic>> get _filteredInventory {
    return _inventory.where((item) {
      final matchesSearch =
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'All' || item['category'] == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onDestinationSelected: _onDestinationSelected,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new inventory item
        },
        child: const Icon(Icons.add),
      ),
      child: _buildInventoryContent(),
    );
  }

  Widget _buildInventoryContent() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Inventory', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_filteredInventory.length} items', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: AppConfig.largePadding),
          _buildFilters(),
          const SizedBox(height: AppConfig.defaultPadding),
          Expanded(child: _buildInventoryList()),
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
            decoration: const InputDecoration(hintText: 'Search inventory...', prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _categoryFilter,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              'All',
              'Business Cards',
              'Flyers',
              'Brochures',
              'Posters',
            ].map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _categoryFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryList() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < AppConfig.mobileBreakpoint ? _buildMobileList() : _buildDesktopTable();
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredInventory.length,
      itemBuilder: (context, index) {
        final item = _filteredInventory[index];
        final isLowStock = item['stock'] <= item['minStock'];

        return Card(
          margin: const EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['category']),
                Text('Stock: ${item['stock']} • \$${item['price'].toStringAsFixed(2)} each'),
                if (isLowStock)
                  Text(
                    'Low Stock!',
                    style: TextStyle(color: AppConfig.errorColor, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit stock
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    // View details
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Min Stock')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Vendor')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredInventory.map((item) {
          final isLowStock = item['stock'] <= item['minStock'];
          return DataRow(
            cells: [
              DataCell(Text(item['id'])),
              DataCell(Text(item['name'])),
              DataCell(Text(item['category'])),
              DataCell(
                Text(
                  item['stock'].toString(),
                  style: isLowStock ? TextStyle(color: AppConfig.errorColor, fontWeight: FontWeight.bold) : null,
                ),
              ),
              DataCell(Text(item['minStock'].toString())),
              DataCell(Text('\$${item['price'].toStringAsFixed(2)}')),
              DataCell(Text(item['vendor'])),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit stock
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View details
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
}
