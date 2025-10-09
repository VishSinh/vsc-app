import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/widgets/bill_filter_dialog.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bill_mobile_card.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bills_desktop_table.dart';

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
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}?').hasMatch(phone) && !RegExp(r'^\d{10}?$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 10-digit phone number')));
      return;
    }
    provider.setServerFilters(phone: phone);
    await provider.getBills(page: 1);
  }

  // Using BillCalculationService for status colors and text

  Widget _buildBillSearchContent(BillProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Search header with responsive layout
              if (context.isDesktop) _buildDesktopSearchRow(provider) else _buildMobileSearchRow(provider),
              const SizedBox(height: 8),
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading bills...')
                    : provider.bills.isEmpty
                    ? const EmptyStateWidget(message: 'No bills found', icon: Icons.receipt_long)
                    : RefreshIndicator(
                        onRefresh: () => provider.getBills(),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            context.isMobile ? _buildMobileList(provider) : _buildDesktopTable(provider),
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
                                  showTotalItems: true,
                                  totalItems: provider.pagination?.totalItems,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSearchRow(BillProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter customer phone number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            onSubmitted: (_) => _search(),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim())
                  ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => BillFilterDialog.show(context),
          icon: Icon(Icons.filter_list, color: provider.hasActiveFilters ? Colors.red : null),
          label: Text('Filters', style: TextStyle(color: provider.hasActiveFilters ? Colors.red : null)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: provider.hasActiveFilters ? Colors.red : Theme.of(context).colorScheme.primary, width: 2),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        if (_phoneController.text.isNotEmpty) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Clear',
            onPressed: () {
              _phoneController.clear();
              final p = context.read<BillProvider>();
              p.setServerFilters(phone: '');
              p.getBills(page: 1);
              setState(() {});
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileSearchRow(BillProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter customer phone number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                onSubmitted: (_) => _search(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_phoneController.text.isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  _phoneController.clear();
                  final p = context.read<BillProvider>();
                  p.setServerFilters(phone: '');
                  p.getBills(page: 1);
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim())
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => BillFilterDialog.show(context),
                icon: Icon(Icons.filter_list, color: provider.hasActiveFilters ? Colors.red : null),
                label: Text('Filters', style: TextStyle(color: provider.hasActiveFilters ? Colors.red : null)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  side: BorderSide(color: provider.hasActiveFilters ? Colors.red : Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileList(BillProvider provider) {
    return ListView.separated(
      itemCount: provider.bills.length,
      separatorBuilder: (_, __) => SizedBox(height: AppConfig.smallPadding),
      itemBuilder: (context, index) => SharedBillMobileCard(
        bill: provider.bills[index],
        onTap: (bill) => context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id}),
      ),
    );
  }

  Widget _buildDesktopTable(BillProvider provider) {
    return SharedBillsDesktopTable(
      bills: provider.bills,
      onTapBill: (bill) => context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id}),
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

// Replaced by SharedBillMobileCard
