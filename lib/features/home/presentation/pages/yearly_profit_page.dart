import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
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
      appBar: AppBar(
        title: const Text('Yearly Profit Analysis'),
        bottom: TabBar(
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
      ),
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

          return TabBarView(
            controller: _tabController,
            children: [
              // Chart View
              ProfitChartWidget(profitData: provider.yearlyProfitData!),

              // List View
              ProfitListWidget(profitData: provider.yearlyProfitData!),
            ],
          );
        },
      ),
    );
  }
}
