import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bill_mobile_card.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bills_desktop_table.dart';

class PendingBillsPage extends StatefulWidget {
  const PendingBillsPage({super.key});

  @override
  State<PendingBillsPage> createState() => _PendingBillsPageState();
}

class _PendingBillsPageState extends State<PendingBillsPage> {
  late final AnalyticsProvider _analyticsProvider;
  @override
  void initState() {
    super.initState();
    _analyticsProvider = context.read<AnalyticsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsProvider.setContext(context);
      _analyticsProvider.getPendingBills();
    });
  }

  @override
  void dispose() {
    _analyticsProvider.clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildToggle(), centerTitle: true),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading pending bills...');
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.getPendingBills());
          }

          final bills = provider.pendingBills ?? [];
          if (bills.isEmpty) return const EmptyStateWidget(message: 'No pending bills', icon: Icons.receipt_long_outlined);

          return context.isDesktop
              ? SharedBillsDesktopTable(bills: bills, onTapBill: (bill) => _openBillDetail(bill))
              : _buildMobileList(bills);
        },
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChoiceChip(label: const Text('Pending Orders'), selected: false, onSelected: (_) => context.go(RouteConstants.pendingOrders)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Bills'), selected: true, onSelected: (_) {}),
      ],
    );
  }

  Widget _buildMobileList(List<BillViewModel> bills) {
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) => SharedBillMobileCard(bill: bills[index], onTap: (bill) => _openBillDetail(bill)),
    );
  }

  void _openBillDetail(BillViewModel bill) {
    context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id});
  }
}
