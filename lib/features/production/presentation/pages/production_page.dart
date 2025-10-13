import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/production/presentation/providers/production_provider.dart';
import 'package:vsc_app/features/production/presentation/models/printer_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/tracing_studio_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<ProductionProvider>();
      p.setContext(context);
      p.resetProduction();
      p.fetchPrinters(page: 1, pageSize: 50);
      p.fetchTracingStudios(page: 1, pageSize: 50);
      p.fetchBoxMakers(page: 1, pageSize: 50);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.only(right: AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Printers (${p.printers.length})'),
                        Tab(text: 'Tracing Studio (${p.tracingStudios.length})'),
                        Tab(text: 'Box Makers (${p.boxMakers.length})'),
                      ],
                    ),
                    SizedBox(height: AppConfig.defaultPadding),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildPrintersTab(p), _buildTracingStudiosTab(p), _buildBoxMakersTab(p)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrintersTab(ProductionProvider p) {
    if (p.isLoadingPrinters) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastPrintersError != null) {
      return _buildErrorState(p.lastPrintersError!, () => p.fetchPrinters());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppConfig.smallPadding),
        DropdownButtonFormField<PrinterViewModel>(
          value: p.printers.contains(p.selectedPrinter) ? p.selectedPrinter : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Select Printer'),
          items: p.printers.map((printer) => DropdownMenuItem<PrinterViewModel>(value: printer, child: Text(printer.name))).toList(),
          onChanged: (value) {
            p.setSelectedPrinter(value);
            p.fetchPrinterItems();
          },
        ),
        SizedBox(height: AppConfig.defaultPadding),
        Expanded(child: _buildPrinterItemsSection(p)),
      ],
    );
  }

  Widget _buildTracingStudiosTab(ProductionProvider p) {
    if (p.isLoadingTracingStudios) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastTracingStudiosError != null) {
      return _buildErrorState(p.lastTracingStudiosError!, () => p.fetchTracingStudios());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppConfig.smallPadding),
        DropdownButtonFormField<TracingStudioViewModel>(
          value: p.tracingStudios.contains(p.selectedTracingStudio) ? p.selectedTracingStudio : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Select Tracing Studio'),
          items: p.tracingStudios.map((t) => DropdownMenuItem<TracingStudioViewModel>(value: t, child: Text(t.name))).toList(),
          onChanged: (value) {
            p.setSelectedTracingStudio(value);
            p.fetchTracingItems();
          },
        ),
        SizedBox(height: AppConfig.defaultPadding),
        Expanded(child: _buildTracingItemsSection(p)),
      ],
    );
  }

  Widget _buildBoxMakersTab(ProductionProvider p) {
    if (p.isLoadingBoxMakers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastBoxMakersError != null) {
      return _buildErrorState(p.lastBoxMakersError!, () => p.fetchBoxMakers());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppConfig.smallPadding),
        DropdownButtonFormField<BoxMakerViewModel>(
          value: p.boxMakers.contains(p.selectedBoxMaker) ? p.selectedBoxMaker : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Select Box Maker'),
          items: p.boxMakers.map((b) => DropdownMenuItem<BoxMakerViewModel>(value: b, child: Text(b.name))).toList(),
          onChanged: (value) {
            p.setSelectedBoxMaker(value);
            p.fetchBoxOrderItems();
          },
        ),
        SizedBox(height: AppConfig.defaultPadding),
        Expanded(child: _buildBoxOrderItemsSection(p)),
      ],
    );
  }

  Widget _buildPrinterItemsSection(ProductionProvider p) {
    if (p.selectedPrinter == null) {
      return _buildSelectionPlaceholder(title: 'Printer', name: null);
    }
    if (p.isLoadingPrinterItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastPrinterItemsError != null) {
      return _buildErrorState(p.lastPrinterItemsError!, () => p.fetchPrinterItems());
    }
    if (p.printerItems.isEmpty) {
      return const Center(child: Text('No records'));
    }
    const double fixedRowHeight = 65.0;
    const double headerHeight = 50.0;
    const double borderRadius = 12.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        RefreshIndicator(
          onRefresh: p.refreshPrintersTab,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!, width: 1),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Column(
                children: [
                  Container(
                    height: headerHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text('Order Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Impressions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: p.printerItems.length,
                      itemBuilder: (context, index) {
                        final item = p.printerItems[index];
                        return Container(
                          height: fixedRowHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF4C4B4B))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: InkWell(
                                    onTap: () =>
                                        context.pushNamed(RouteConstants.orderDetailRouteName, pathParameters: {'id': item.orderId}),
                                    child: Text(
                                      item.orderName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    item.impressions.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      item.printerPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: item.printerPaid ? Colors.green : Colors.grey,
                                    ),
                                    tooltip: 'Toggle paid',
                                    onPressed: () => p.togglePrinterPaid(item.printingJobId, !item.printerPaid),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (p.printerItemsPagination != null)
          Positioned(
            bottom: 10,
            child: PaginationWidget(
              currentPage: p.printerItemsPagination!.currentPage,
              totalPages: p.printerItemsPagination!.totalPages,
              hasPrevious: p.printerItemsPagination!.hasPrevious,
              hasNext: p.printerItemsPagination!.hasNext,
              onPreviousPage: p.loadPrevPrinterItemsPage,
              onNextPage: p.loadNextPrinterItemsPage,
              showTotalItems: true,
              totalItems: p.printerItemsPagination!.totalItems,
            ),
          ),
      ],
    );
  }

  Widget _buildTracingItemsSection(ProductionProvider p) {
    if (p.selectedTracingStudio == null) {
      return _buildSelectionPlaceholder(title: 'Tracing Studio', name: null);
    }
    if (p.isLoadingTracingItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastTracingItemsError != null) {
      return _buildErrorState(p.lastTracingItemsError!, () => p.fetchTracingItems());
    }
    if (p.tracingItems.isEmpty) {
      return const Center(child: Text('No records'));
    }
    const double fixedRowHeight = 65.0;
    const double headerHeight = 50.0;
    const double borderRadius = 12.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        RefreshIndicator(
          onRefresh: p.refreshTracingTab,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!, width: 1),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Column(
                children: [
                  Container(
                    height: headerHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text('Order Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: p.tracingItems.length,
                      itemBuilder: (context, index) {
                        final item = p.tracingItems[index];
                        return Container(
                          height: fixedRowHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF4C4B4B))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: InkWell(
                                    onTap: () =>
                                        context.pushNamed(RouteConstants.orderDetailRouteName, pathParameters: {'id': item.orderId}),
                                    child: Text(
                                      item.orderName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      item.tracingStudioPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: item.tracingStudioPaid ? Colors.green : Colors.grey,
                                    ),
                                    tooltip: 'Toggle paid',
                                    onPressed: () => p.toggleTracingPaid(item.printingJobId, !item.tracingStudioPaid),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (p.tracingItemsPagination != null)
          Positioned(
            bottom: 10,
            child: PaginationWidget(
              currentPage: p.tracingItemsPagination!.currentPage,
              totalPages: p.tracingItemsPagination!.totalPages,
              hasPrevious: p.tracingItemsPagination!.hasPrevious,
              hasNext: p.tracingItemsPagination!.hasNext,
              onPreviousPage: p.loadPrevTracingItemsPage,
              onNextPage: p.loadNextTracingItemsPage,
              showTotalItems: true,
              totalItems: p.tracingItemsPagination!.totalItems,
            ),
          ),
      ],
    );
  }

  Widget _buildBoxOrderItemsSection(ProductionProvider p) {
    if (p.selectedBoxMaker == null) {
      return _buildSelectionPlaceholder(title: 'Box Maker', name: null);
    }
    if (p.isLoadingBoxOrderItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.lastBoxOrderItemsError != null) {
      return _buildErrorState(p.lastBoxOrderItemsError!, () => p.fetchBoxOrderItems());
    }
    if (p.boxOrderItems.isEmpty) {
      return const Center(child: Text('No records'));
    }
    const double fixedRowHeight = 65.0;
    const double headerHeight = 50.0;
    const double borderRadius = 12.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        RefreshIndicator(
          onRefresh: p.refreshBoxMakersTab,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!, width: 1),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Column(
                children: [
                  Container(
                    height: headerHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text('Order Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: p.boxOrderItems.length,
                      itemBuilder: (context, index) {
                        final item = p.boxOrderItems[index];
                        return Container(
                          height: fixedRowHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF4C4B4B))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: InkWell(
                                    onTap: () =>
                                        context.pushNamed(RouteConstants.orderDetailRouteName, pathParameters: {'id': item.orderId}),
                                    child: Text(
                                      item.orderName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      item.boxMakerPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: item.boxMakerPaid ? Colors.green : Colors.grey,
                                    ),
                                    tooltip: 'Toggle paid',
                                    onPressed: () => p.toggleBoxMakerPaid(item.boxOrderId, !item.boxMakerPaid),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (p.boxOrderItemsPagination != null)
          Positioned(
            bottom: 10,
            child: PaginationWidget(
              currentPage: p.boxOrderItemsPagination!.currentPage,
              totalPages: p.boxOrderItemsPagination!.totalPages,
              hasPrevious: p.boxOrderItemsPagination!.hasPrevious,
              hasNext: p.boxOrderItemsPagination!.hasNext,
              onPreviousPage: p.loadPrevBoxOrderItemsPage,
              onNextPage: p.loadNextBoxOrderItemsPage,
              showTotalItems: true,
              totalItems: p.boxOrderItemsPagination!.totalItems,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionPlaceholder({required String title, String? name}) {
    final hasSelection = name != null && name.isNotEmpty;
    return Card(
      child: Center(
        child: Text(
          hasSelection
              ? 'Selected $title: $name\n\nTable placeholder — data API to be wired later.'
              : 'Select a $title to view its data here',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, Future<void> Function() onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: AppConfig.smallPadding),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
