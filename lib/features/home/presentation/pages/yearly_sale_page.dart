import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_sale_view_model.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/home/presentation/widgets/sale_chart_widget.dart';
import 'package:vsc_app/features/home/presentation/widgets/sale_list_widget.dart';

class YearlySalePage extends StatefulWidget {
  const YearlySalePage({Key? key}) : super(key: key);

  @override
  State<YearlySalePage> createState() => _YearlySalePageState();
}

class _YearlySalePageState extends State<YearlySalePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.fetchYearlySaleData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<AnalyticsProvider>().clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.fetchYearlySaleData());
          }

          if (provider.yearlySaleData == null || provider.yearlySaleData!.isEmpty) {
            return const EmptyStateWidget(message: 'No sale data available', icon: Icons.analytics_outlined);
          }

          return context.isDesktop ? _buildDesktopLayout(provider.yearlySaleData!) : _buildMobileLayout(provider.yearlySaleData!);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDesktop = context.isDesktop;

    return AppBar(
      title: Text(isDesktop ? 'Yearly Sale Analysis' : 'Sale Analysis'),
      bottom: isDesktop
          ? null
          : TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart), text: 'Chart'),
                Tab(icon: Icon(Icons.list), text: 'Details'),
              ],
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<AnalyticsProvider>().fetchYearlySaleData(),
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<dynamic> yearlySaleData) {
    final typedData = yearlySaleData.cast<YearlySaleViewModel>();
    return Padding(
      padding: context.responsivePadding,
      child: Row(
        children: [
          // Chart takes 60% of the width
          Expanded(
            flex: 6,
            child: Card(
              elevation: 2,
              margin: EdgeInsets.only(right: context.responsiveSpacing / 2),
              child: SaleChartWidget(saleData: typedData),
            ),
          ),
          SizedBox(width: context.responsiveSpacing),
          // List takes 40% of the width
          Expanded(
            flex: 4,
            child: Card(
              elevation: 2,
              margin: EdgeInsets.only(left: context.responsiveSpacing / 2),
              child: SaleListWidget(saleData: typedData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<dynamic> yearlySaleData) {
    final typedData = yearlySaleData.cast<YearlySaleViewModel>();
    return TabBarView(
      controller: _tabController,
      children: [
        // Chart View
        SaleChartWidget(saleData: typedData),

        // List View
        SaleListWidget(saleData: typedData),
      ],
    );
  }
}
