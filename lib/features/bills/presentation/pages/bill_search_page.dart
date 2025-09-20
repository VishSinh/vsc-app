import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';

import 'package:vsc_app/features/bills/presentation/services/bill_calculation_service.dart';

class BillSearchPage extends StatefulWidget {
  const BillSearchPage({super.key});

  @override
  State<BillSearchPage> createState() => _BillSearchPageState();
}

class _BillSearchPageState extends State<BillSearchPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                    ? const LoadingWidget(message: 'Searching bills...')
                    : provider.bills.isEmpty
                    ? const EmptyStateWidget(message: 'Search for bills by phone number', icon: Icons.receipt_long)
                    : ListView.builder(
                        itemCount: provider.bills.length,
                        itemBuilder: (context, index) {
                          final bill = provider.bills[index];
                          return GestureDetector(
                            onTap: () => context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id}),
                            child: Card(
                              margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                              elevation: 2,
                              child: Padding(
                                padding: context.responsivePadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            bill.orderName,
                                            style: ResponsiveText.getTitle(context).copyWith(fontSize: context.isMobile ? 16 : 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: AppConfig.smallPadding, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: BillCalculationService.getStatusColor(bill.paymentStatus),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            BillCalculationService.getStatusText(bill.paymentStatus),
                                            style: ResponsiveText.getCaption(
                                              context,
                                            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.isMobile ? 10 : 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppConfig.smallPadding),
                                    Row(
                                      children: [
                                        Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Text(
                                          'Order',
                                          style: ResponsiveText.getBody(
                                            context,
                                          ).copyWith(color: Colors.grey[600], fontSize: context.isMobile ? 12 : 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppConfig.smallPadding),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Items: ${bill.order.orderItems.length}',
                                              style: ResponsiveText.getBody(context).copyWith(fontSize: context.isMobile ? 12 : 14),
                                            ),
                                            Text(
                                              'Tax: ${bill.summary.formattedTaxPercentage}',
                                              style: ResponsiveText.getCaption(
                                                context,
                                              ).copyWith(color: Colors.grey[600], fontSize: context.isMobile ? 10 : 12),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              bill.summary.formattedTotalWithTax,
                                              style: ResponsiveText.getSubtitle(context).copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppConfig.textColorPrimary,
                                                fontSize: context.isMobile ? 14 : 18,
                                              ),
                                            ),
                                            Text(
                                              'Grand Total',
                                              style: ResponsiveText.getCaption(
                                                context,
                                              ).copyWith(color: Colors.grey[600], fontSize: context.isMobile ? 10 : 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
      ],
    );
  }

  Widget _buildMobileSearchRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
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
