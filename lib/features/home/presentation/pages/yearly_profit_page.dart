import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_profit_view_model.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/home/presentation/widgets/profit_chart_widget.dart';
import 'package:vsc_app/features/home/presentation/widgets/profit_list_widget.dart';

class YearlyProfitPage extends StatefulWidget {
  const YearlyProfitPage({Key? key}) : super(key: key);

  @override
  State<YearlyProfitPage> createState() => _YearlyProfitPageState();
}

class _YearlyProfitPageState extends State<YearlyProfitPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.fetchYearlyProfitData();
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
            return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.fetchYearlyProfitData());
          }

          if (provider.yearlyProfitData == null || provider.yearlyProfitData!.isEmpty) {
            return const EmptyStateWidget(message: 'No profit data available', icon: Icons.analytics_outlined);
          }

          return context.isDesktop ? _buildDesktopLayout(provider.yearlyProfitData!) : _buildMobileLayout(provider.yearlyProfitData!);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDesktop = context.isDesktop;

    return AppBar(
      title: Text(isDesktop ? 'Yearly Profit Analysis' : 'Profit Analysis'),
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
          onPressed: () => context.read<AnalyticsProvider>().fetchYearlyProfitData(),
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<dynamic> yearlyProfitData) {
    final typedData = yearlyProfitData.cast<YearlyProfitViewModel>();
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
              child: ProfitChartWidget(profitData: typedData),
            ),
          ),
          SizedBox(width: context.responsiveSpacing),
          // List takes 40% of the width
          Expanded(
            flex: 4,
            child: Card(
              elevation: 2,
              margin: EdgeInsets.only(left: context.responsiveSpacing / 2),
              child: ProfitListWidget(profitData: typedData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<dynamic> yearlyProfitData) {
    final typedData = yearlyProfitData.cast<YearlyProfitViewModel>();
    return TabBarView(
      controller: _tabController,
      children: [
        // Chart View
        ProfitChartWidget(profitData: typedData),

        // List View
        ProfitListWidget(profitData: typedData),
      ],
    );
  }
}
