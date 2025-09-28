import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/core/enums/bill_status.dart';

class BillSearchPage extends StatefulWidget {
  const BillSearchPage({super.key});

  @override
  State<BillSearchPage> createState() => _BillSearchPageState();
}

class _BillSearchPageState extends State<BillSearchPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-fetch all bills on page load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<BillProvider>();
      provider.setContext(context);
      await provider.getBills();
    });
  }

  Future<void> _search() async {
    final provider = context.read<BillProvider>();
    provider.setContext(context);
    await provider.getBillByPhone(phone: _phoneController.text.trim());
  }

  // Using BillCalculationService for status colors and text

  Widget _buildBillSearchContent(BillProvider provider) {
    return Padding(
      padding: context.responsivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search header with responsive layout
              if (context.isDesktop) _buildDesktopSearchRow() else _buildMobileSearchRow(),
              SizedBox(height: context.responsiveSpacing),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading bills...')
                    : provider.bills.isEmpty
                    ? const EmptyStateWidget(message: 'No bills found', icon: Icons.receipt_long)
                    : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ListView.separated(
                            itemCount: provider.bills.length,
                            separatorBuilder: (_, __) => SizedBox(height: AppConfig.smallPadding),
                            itemBuilder: (context, index) {
                              final bill = provider.bills[index];
                              return _BillListTile(
                                bill: bill,
                                onTap: () => context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id}),
                              );
                            },
                          ),
                          if (provider.pagination != null)
                            Positioned(
                              bottom: 10,
                              child: PaginationWidget(
                                currentPage: provider.pagination?.currentPage ?? 1,
                                totalPages: provider.pagination?.totalPages ?? 1,
                                hasPrevious: provider.pagination?.hasPrevious ?? false,
                                hasNext: provider.hasMoreBills,
                                onPreviousPage: provider.pagination?.hasPrevious ?? false ? () => provider.loadPreviousPage() : null,
                                onNextPage: provider.hasMoreBills ? () => provider.loadNextPage() : null,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSearchRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter customer phone number',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _search(),
          ),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          flex: 1,
          child: ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), minimumSize: Size(120, 56)),
          ),
        ),
        if (_phoneController.text.isNotEmpty) ...[
          SizedBox(width: AppConfig.smallPadding),
          IconButton(
            tooltip: 'Clear',
            onPressed: () {
              _phoneController.clear();
              context.read<BillProvider>().getBills();
              setState(() {});
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileSearchRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter customer phone number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onSubmitted: (_) => _search(),
              ),
            ),
            if (_phoneController.text.isNotEmpty) ...[
              SizedBox(width: AppConfig.smallPadding),
              IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  _phoneController.clear();
                  context.read<BillProvider>().getBills();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        SizedBox(height: AppConfig.smallPadding),
        ElevatedButton.icon(
          onPressed: _search,
          icon: const Icon(Icons.search),
          label: const Text('Search'),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        return _buildBillSearchContent(provider);
      },
    );
  }
}

class _BillListTile extends StatelessWidget {
  final BillViewModel bill;
  final VoidCallback? onTap;

  const _BillListTile({required this.bill, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppConfig.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.receipt_long, size: 20, color: AppConfig.accentColor),
        ),
        title: Text(
          bill.orderName,
          style: ResponsiveText.getTitle(context).copyWith(fontSize: context.isMobile ? 16 : 18, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Items: ${bill.order.orderItems.length}',
                style: ResponsiveText.getBody(context).copyWith(fontSize: context.isMobile ? 12 : 13, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              bill.summary.formattedTotalWithTax,
              style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold, fontSize: context.isMobile ? 14 : 16),
            ),
            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                final color = bill.paymentStatus.getStatusColor();
                return Text(
                  bill.paymentStatus.getDisplayText(),
                  style: ResponsiveText.getCaption(context).copyWith(color: color, fontWeight: FontWeight.w600),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
