import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shimmer_widgets.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/snackbar_constants.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 2; // Inventory tab
  String _searchQuery = '';
  String _categoryFilter = 'All';
  bool _showInventoryTable = false;
  bool _isLoading = true; // Simulate loading state

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
    const NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard),
    const NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders),
    const NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory),
    const NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production),
    const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go(RouteConstants.dashboard);
        break;
      case 1:
        context.go(RouteConstants.orders);
        break;
      case 2:
        break; // Already on inventory
      case 3:
        context.go(RouteConstants.production);
        break;
      case 4:
        context.go(RouteConstants.administration);
        break;
    }
  }

  List<Map<String, dynamic>> get _filteredInventory {
    return _inventory.where((item) {
      final matchesSearch =
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == UITextConstants.categoryAll || item['category'] == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Check if permissions are loaded, if not show shimmer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionProvider = context.read<PermissionProvider>();
      if (!permissionProvider.isInitialized) {
        // Show shimmer while permissions load
        setState(() {
          _isLoading = true;
        });

        // Wait for permissions to load
        permissionProvider
            .initializePermissions()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
      } else {
        // Permissions already loaded, hide shimmer
        setState(() {
          _isLoading = false;
        });
      }
    });
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
          // Page Header
          Row(
            children: [
              Icon(Icons.inventory, color: AppConfig.primaryColor, size: AppConfig.iconSizeXXLarge),
              const SizedBox(width: AppConfig.defaultPadding),
              Text(UITextConstants.inventoryManagementTitle, style: AppConfig.headlineStyle.copyWith(color: AppConfig.primaryColor)),
            ],
          ),
          const SizedBox(height: AppConfig.smallPadding),
          Text(UITextConstants.inventoryManagementSubtitle, style: AppConfig.subtitleStyle),
          const SizedBox(height: AppConfig.largePadding),

          // Quick Actions Section
          _buildQuickActions(),
          const SizedBox(height: AppConfig.largePadding),

          // Inventory Table Section
          _buildInventoryTableSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(UITextConstants.quickActions, style: AppConfig.titleStyle),
        const SizedBox(height: AppConfig.defaultPadding),
        Wrap(
          spacing: AppConfig.defaultPadding,
          runSpacing: AppConfig.defaultPadding,
          children: [
            ButtonUtils.primaryButton(onPressed: () => context.go(RouteConstants.createCard), label: UITextConstants.addCards, icon: Icons.add_card),
            ButtonUtils.accentButton(
              onPressed: () {
                // TODO: Navigate to get card page
                SnackbarUtils.showInfo(context, SnackbarConstants.getCardComingSoon);
              },
              label: UITextConstants.getCard,
              icon: Icons.search,
            ),
            ButtonUtils.secondaryButton(
              onPressed: () {
                // TODO: Navigate to find similar card page
                SnackbarUtils.showInfo(context, SnackbarConstants.findSimilarCardComingSoon);
              },
              label: UITextConstants.findSimilarCard,
              icon: Icons.compare_arrows,
            ),
            ButtonUtils.warningButton(
              onPressed: () {
                // Show inventory table
                setState(() {
                  _showInventoryTable = true;
                });
              },
              label: UITextConstants.viewInventory,
              icon: Icons.table_chart,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryTableSection() {
    if (!_showInventoryTable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Inventory Items', style: AppConfig.titleStyle),
            const Spacer(),
            Text('${_filteredInventory.length} items', style: AppConfig.captionStyle),
            const SizedBox(width: AppConfig.defaultPadding),
            ButtonUtils.dangerButton(
              onPressed: () {
                setState(() {
                  _showInventoryTable = false;
                });
              },
              label: UITextConstants.hideTable,
              icon: Icons.close,
            ),
          ],
        ),
        const SizedBox(height: AppConfig.defaultPadding),
        _buildFilters(),
        const SizedBox(height: AppConfig.defaultPadding),
        Expanded(child: _isLoading ? _buildShimmerSkeleton() : _buildInventoryList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              hintStyle: AppConfig.captionStyle,
              labelStyle: AppConfig.bodyStyle,
            ),
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
            decoration: InputDecoration(labelText: 'Category', labelStyle: AppConfig.bodyStyle),
            items: ['All', 'Business Cards', 'Flyers', 'Brochures', 'Posters']
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category, style: AppConfig.bodyStyle),
                  ),
                )
                .toList(),
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
            title: Text(item['name'], style: AppConfig.bodyStyle.copyWith(fontWeight: AppConfig.fontWeightBold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['category'], style: AppConfig.bodyStyle),
                Text('Stock: ${item['stock']} • \$${item['price'].toStringAsFixed(2)} each', style: AppConfig.captionStyle),
                if (isLowStock)
                  Text(
                    'Low Stock!',
                    style: AppConfig.bodyStyle.copyWith(color: AppConfig.errorColor, fontWeight: AppConfig.fontWeightBold),
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
        columns: [
          DataColumn(label: Text('Item ID', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Name', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Category', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Stock', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Min Stock', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Price', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Vendor', style: AppConfig.bodyStyle)),
          DataColumn(label: Text('Actions', style: AppConfig.bodyStyle)),
        ],
        rows: _filteredInventory.map((item) {
          final isLowStock = item['stock'] <= item['minStock'];
          return DataRow(
            cells: [
              DataCell(Text(item['id'], style: AppConfig.bodyStyle)),
              DataCell(Text(item['name'], style: AppConfig.bodyStyle)),
              DataCell(Text(item['category'], style: AppConfig.bodyStyle)),
              DataCell(
                Text(
                  item['stock'].toString(),
                  style: isLowStock
                      ? AppConfig.bodyStyle.copyWith(color: AppConfig.errorColor, fontWeight: AppConfig.fontWeightBold)
                      : AppConfig.bodyStyle,
                ),
              ),
              DataCell(Text(item['minStock'].toString(), style: AppConfig.bodyStyle)),
              DataCell(Text('\$${item['price'].toStringAsFixed(2)}', style: AppConfig.bodyStyle)),
              DataCell(Text(item['vendor'], style: AppConfig.bodyStyle)),
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

  Widget _buildShimmerSkeleton() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < AppConfig.mobileBreakpoint) {
      // Mobile shimmer skeleton
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return const ShimmerWrapper(child: ListItemSkeleton());
        },
      );
    } else {
      // Desktop shimmer skeleton
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Item ID', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Name', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Category', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Stock', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Min Stock', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Price', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Vendor', style: AppConfig.bodyStyle)),
            DataColumn(label: Text('Actions', style: AppConfig.bodyStyle)),
          ],
          rows: List.generate(6, (index) {
            return DataRow(
              cells: List.generate(8, (cellIndex) {
                return DataCell(
                  ShimmerWrapper(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      );
    }
  }
}
