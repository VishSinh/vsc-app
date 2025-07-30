import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/shimmer_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/features/vendors/presentation/widgets/create_vendor_dialog.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  int _selectedIndex = 0; // Will be set based on permissions
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 VendorsPage: Loading vendors...');
      context.read<VendorProvider>().loadVendors();
      _setSelectedIndex();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: _selectedIndex,
      destinations: _getDestinations(),
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });

        final destinations = _getDestinations();
        final route = NavigationItems.getRouteForIndex(index, destinations);
        if (route != '/vendors') {
          context.go(route);
        }
      },
      pageTitle: UITextConstants.vendors,
      child: _buildVendorsContent(),
    );
  }

  Widget _buildVendorsContent() {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          PageHeader(
            title: UITextConstants.vendors,
            actions: [
              Consumer<PermissionProvider>(
                builder: (context, permissionProvider, child) {
                  if (permissionProvider.canCreate('vendor')) {
                    return ActionButton(label: UITextConstants.addVendor, icon: Icons.add, onPressed: _showCreateVendorDialog);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),

          SearchField(
            controller: _searchController,
            hintText: 'Search vendors...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          SizedBox(height: context.responsiveSpacing),

          // Vendors List
          Expanded(
            child: Consumer<VendorProvider>(
              builder: (context, vendorProvider, child) {
                if (vendorProvider.isLoading && vendorProvider.vendors.isEmpty) {
                  return _buildShimmerSkeleton();
                }

                if (vendorProvider.errorMessage != null) {
                  return CustomErrorWidget(message: vendorProvider.errorMessage!, onRetry: () => vendorProvider.refreshVendors());
                }

                final filteredVendors = vendorProvider.getFilteredVendors(_searchQuery);

                if (filteredVendors.isEmpty) {
                  return EmptyStateWidget(
                    message: _searchQuery.isNotEmpty ? 'No vendors found matching your search' : 'No vendors found',
                    icon: Icons.people_outline,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => vendorProvider.refreshVendors(),
                  child: ListView.builder(
                    itemCount: filteredVendors.length + (vendorProvider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredVendors.length) {
                        // Load more indicator
                        if (vendorProvider.hasMoreData && !vendorProvider.isLoading) {
                          vendorProvider.loadMoreVendors();
                        }
                        return vendorProvider.isLoading
                            ? Padding(
                                padding: EdgeInsets.all(AppConfig.defaultPadding),
                                child: const Center(child: LoadingWidget()),
                              )
                            : const SizedBox.shrink();
                      }

                      final vendor = filteredVendors[index];
                      return _buildVendorCard(vendor);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return ListItemCard(
      leading: CircleAvatar(
        backgroundColor: vendor.isActive ? AppConfig.successColor : AppConfig.grey400,
        child: const Icon(Icons.business, color: AppConfig.textColorPrimary),
      ),
      title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(vendor.phone),
      trailing: StatusBadge(text: vendor.isActive ? 'Active' : 'Inactive', isActive: vendor.isActive),
      onTap: () {
        // Navigate to vendor details page
        print('🖱️ VendorsPage: Tapped vendor card for ID: ${vendor.id}');
        print('🖱️ VendorsPage: Vendor name: ${vendor.name}');
        context.goNamed(RouteConstants.vendorDetailRouteName, pathParameters: {'id': vendor.id});
      },
    );
  }

  void _showCreateVendorDialog() {
    showDialog(context: context, builder: (context) => const CreateVendorDialog());
  }

  Widget _buildShimmerSkeleton() {
    return ListView.builder(
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return const ShimmerWrapper(child: ListItemSkeleton());
      },
    );
  }

  List<NavigationDestination> _getDestinations() {
    final permissionProvider = context.read<PermissionProvider>();
    return NavigationItems.getDestinationsForPermissions(
      canManageOrders: permissionProvider.canManageOrders,
      canManageInventory: permissionProvider.canManageInventory,
      canManageProduction: permissionProvider.canManageProduction,
      canManageVendors: permissionProvider.canManageVendors,
      canManageSystem: permissionProvider.canManageSystem,
      canViewAuditLogs: permissionProvider.canViewAuditLogs,
    );
  }

  void _setSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final destinations = _getDestinations();
        final index = NavigationItems.getSelectedIndexForPage('vendors', destinations);
        setState(() {
          _selectedIndex = index;
        });
      }
    });
  }
}
