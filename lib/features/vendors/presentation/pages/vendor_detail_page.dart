import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/features/vendors/presentation/widgets/create_vendor_dialog.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

class VendorDetailPage extends StatefulWidget {
  final String vendorId;

  const VendorDetailPage({super.key, required this.vendorId});

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  Vendor? _vendor;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVendorDetails();
  }

  Future<void> _loadVendorDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔍 Loading vendor details for ID: ${widget.vendorId}');

      final vendorProvider = context.read<VendorProvider>();
      final vendor = await vendorProvider.getVendorById(widget.vendorId);

      print('📦 Vendor data received: $vendor');
      print('📦 Vendor is null: ${vendor == null}');
      print('📦 Vendor type: ${vendor.runtimeType}');

      if (mounted) {
        setState(() {
          _vendor = vendor;
          _isLoading = false;
          // If vendor is null, set an error message
          if (vendor == null) {
            _errorMessage = 'Vendor not found or no longer available';
          }
        });
      }
    } catch (e) {
      print('❌ Error loading vendor details: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: 0,
      destinations: const [NavigationDestination(icon: Icon(Icons.people), label: UITextConstants.vendors)],
      onDestinationSelected: (index) {},
      pageTitle: 'Vendor Details',
      child: _buildVendorDetailContent(),
    );
  }

  Widget _buildVendorDetailContent() {
    return Padding(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button and actions
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.vendors)),
              SizedBox(width: AppConfig.smallPadding),
              Expanded(
                child: PageHeader(title: 'Vendor Details', actions: _buildActionButtons()),
              ),
            ],
          ),
          SizedBox(height: AppConfig.largePadding),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    if (_vendor == null) return [];

    return [
      Consumer<PermissionProvider>(
        builder: (context, permissionProvider, child) {
          final canEdit = permissionProvider.canUpdate('vendor');
          final canDelete = permissionProvider.canDelete('vendor');

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit) ActionButton(label: 'Edit', icon: Icons.edit, onPressed: _showEditVendorDialog),
              if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
              if (canDelete)
                ActionButton(label: 'Delete', icon: Icons.delete, onPressed: _showDeleteConfirmation, backgroundColor: AppConfig.errorColor),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: SpinKitDoubleBounce(color: AppConfig.primaryColor, size: AppConfig.loadingIndicatorSize),
      );
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _loadVendorDetails);
    }

    if (_vendor == null) {
      return const EmptyStateWidget(message: 'Vendor not found', icon: Icons.person_off);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVendorCard(),
          SizedBox(height: AppConfig.largePadding),
          _buildVendorInfo(),
          SizedBox(height: AppConfig.largePadding),
          _buildVendorStats(),
        ],
      ),
    );
  }

  Widget _buildVendorCard() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _vendor!.isActive ? AppConfig.successColor : AppConfig.grey400,
              child: const Icon(Icons.business, size: 40, color: AppConfig.textColorPrimary),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vendor!.name,
                    style: TextStyle(fontSize: AppConfig.fontSizeXl, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Text(
                    _vendor!.phone,
                    style: TextStyle(fontSize: AppConfig.fontSizeLg, color: AppConfig.textColorSecondary),
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  StatusBadge(text: _vendor!.isActive ? 'Active' : 'Inactive', isActive: _vendor!.isActive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Information',
              style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            _buildInfoRow('ID', _vendor!.id),
            _buildInfoRow('Name', _vendor!.name),
            _buildInfoRow('Phone', _vendor!.phone),
            _buildInfoRow('Status', _vendor!.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorStats() {
    return Card(
      elevation: AppConfig.elevationLow,
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Orders', '0', Icons.shopping_cart, AppConfig.primaryColor)),
                SizedBox(width: AppConfig.defaultPadding),
                Expanded(child: _buildStatCard('Total Revenue', '₹0', Icons.attach_money, AppConfig.successColor)),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(child: _buildStatCard('Products', '0', Icons.inventory, AppConfig.warningColor)),
                SizedBox(width: AppConfig.defaultPadding),
                Expanded(child: _buildStatCard('Rating', 'N/A', Icons.star, AppConfig.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            title,
            style: TextStyle(fontSize: AppConfig.fontSizeSm, color: AppConfig.textColorSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditVendorDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateVendorDialog(vendor: _vendor, isEditing: true),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vendor'),
        content: Text('Are you sure you want to delete ${_vendor!.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteVendor();
            },
            style: TextButton.styleFrom(foregroundColor: AppConfig.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVendor() async {
    try {
      final vendorProvider = context.read<VendorProvider>();
      final success = await vendorProvider.deleteVendor(id: _vendor!.id);

      if (success && mounted) {
        SnackbarUtils.showSuccess(context, 'Vendor deleted successfully!');
        context.go(RouteConstants.vendors);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to delete vendor: $e');
      }
    }
  }
}
