import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/features/vendors/presentation/widgets/create_vendor_dialog.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

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

      AppLogger.service('VendorDetailPage', 'Loading vendor details for ID: ${widget.vendorId}');

      final vendorProvider = context.read<VendorProvider>();
      final vendor = await vendorProvider.getVendorById(widget.vendorId);

      AppLogger.debug('VendorDetailPage: Vendor data received: $vendor');
      AppLogger.debug('VendorDetailPage: Vendor is null: ${vendor == null}');
      AppLogger.debug('VendorDetailPage: Vendor type: ${vendor.runtimeType}');

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
      AppLogger.errorCaught('VendorDetailPage._loadVendorDetails', e.toString(), errorObject: e);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(UITextConstants.vendorDetails),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: _buildActionButtons(),
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _errorMessage != null
          ? CustomErrorWidget(message: _errorMessage!, onRetry: _loadVendorDetails)
          : _vendor == null
          ? const EmptyStateWidget(message: 'Vendor not found', icon: Icons.person_off)
          : SingleChildScrollView(
              padding: context.responsivePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: context.responsivePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vendor Card
                          _buildVendorCard(),
                          SizedBox(height: context.responsiveSpacing),

                          // Vendor Information
                          _buildVendorInfo(),
                          SizedBox(height: context.responsiveSpacing),

                          // Vendor Statistics
                          _buildVendorStats(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
              if (canEdit) IconButton(icon: const Icon(Icons.edit), onPressed: _showEditVendorDialog, tooltip: UITextConstants.edit),
              if (canEdit && canDelete) SizedBox(width: AppConfig.smallPadding),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showDeleteConfirmation,
                  tooltip: UITextConstants.delete,
                  color: AppConfig.errorColor,
                ),
            ],
          );
        },
      ),
    ];
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
                  Text(_vendor!.name, style: ResponsiveText.getHeadline(context)),
                  SizedBox(height: AppConfig.smallPadding),
                  Text(_vendor!.phone, style: ResponsiveText.getSubtitle(context)),
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
    return InfoDisplayCard(
      title: 'Vendor Information',
      infoRows: [
        InfoRow(label: 'ID', value: _vendor!.id, labelWidth: 100),
        InfoRow(label: 'Name', value: _vendor!.name, labelWidth: 100),
        InfoRow(label: 'Phone', value: _vendor!.phone, labelWidth: 100),
        InfoRow(label: 'Status', value: _vendor!.isActive ? 'Active' : 'Inactive', labelWidth: 100),
      ],
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
            if (context.isDesktop) ...[
              // Desktop: 2x2 grid
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
            ] else ...[
              // Mobile/Tablet: 2x2 grid with smaller spacing
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Orders', '0', Icons.shopping_cart, AppConfig.primaryColor)),
                  SizedBox(width: AppConfig.smallPadding),
                  Expanded(child: _buildStatCard('Total Revenue', '₹0', Icons.attach_money, AppConfig.successColor)),
                ],
              ),
              SizedBox(height: AppConfig.smallPadding),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Products', '0', Icons.inventory, AppConfig.warningColor)),
                  SizedBox(width: AppConfig.smallPadding),
                  Expanded(child: _buildStatCard('Rating', 'N/A', Icons.star, AppConfig.primaryColor)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.isDesktop ? 28 : 24),
          SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: ResponsiveText.getTitle(context).copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: AppConfig.smallPadding),
          Text(title, style: ResponsiveText.getCaption(context), textAlign: TextAlign.center),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(UITextConstants.cancel)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteVendor();
            },
            style: TextButton.styleFrom(foregroundColor: AppConfig.errorColor),
            child: Text(UITextConstants.delete),
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
