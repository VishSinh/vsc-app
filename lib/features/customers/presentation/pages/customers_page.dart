import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/customers/presentation/providers/customer_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:flutter/services.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<CustomerListProvider>();
        provider.setContext(context);
        provider.loadCustomers(pageSize: 30);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(UITextConstants.customers)),
      body: Padding(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<CustomerListProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search by phone number'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),
                    ),
                    SizedBox(width: AppConfig.smallPadding),
                    ElevatedButton.icon(
                      onPressed: () {
                        final phone = _phoneController.text.trim();
                        if (phone.length == 10) {
                          provider.searchByPhone(phone);
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('Enter a valid 10-digit phone number')));
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                    SizedBox(width: AppConfig.smallPadding),
                    OutlinedButton.icon(
                      onPressed: () {
                        _phoneController.clear();
                        provider.loadCustomers(page: 1, pageSize: 30);
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Expanded(
              child: Consumer<CustomerListProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.customers.isEmpty) {
                    return const LoadingWidget(message: 'Loading customers...');
                  }

                  if (provider.errorMessage != null) {
                    return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.refreshCustomers());
                  }

                  if (provider.customers.isEmpty) {
                    return const EmptyStateWidget(message: 'No customers found', icon: Icons.people_outline);
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.refreshCustomers(),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        context.isMobile
                            ? ListView.separated(
                                itemCount: provider.customers.length,
                                separatorBuilder: (context, index) => SizedBox(height: AppConfig.smallPadding),
                                itemBuilder: (context, index) {
                                  final c = provider.customers[index];
                                  return ListItemCard(
                                    leading: CircleAvatar(
                                      backgroundColor: c.isActive ? AppConfig.successColor : AppConfig.grey400,
                                      child: const Icon(Icons.person, color: AppConfig.textColorPrimary),
                                    ),
                                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(c.phone),
                                    onTap: () =>
                                        context.pushNamed(RouteConstants.customerDetailRouteName, pathParameters: {'id': c.id}),
                                  );
                                },
                              )
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 3.2,
                                ),
                                itemCount: provider.customers.length,
                                itemBuilder: (context, index) {
                                  final c = provider.customers[index];
                                  return ListItemCard(
                                    leading: CircleAvatar(
                                      backgroundColor: c.isActive ? AppConfig.successColor : AppConfig.grey400,
                                      child: const Icon(Icons.person, color: AppConfig.textColorPrimary),
                                    ),
                                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(c.phone),
                                    onTap: () =>
                                        context.pushNamed(RouteConstants.customerDetailRouteName, pathParameters: {'id': c.id}),
                                    margin: EdgeInsets.zero,
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
                              hasNext: provider.pagination?.hasNext ?? false,
                              onPreviousPage: provider.pagination?.hasPrevious ?? false ? () => provider.loadPreviousPage() : null,
                              onNextPage: provider.pagination?.hasNext ?? false ? () => provider.loadNextPage() : null,
                              showTotalItems: true,
                              totalItems: provider.pagination?.totalItems,
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
    );
  }
}
