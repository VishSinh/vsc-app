import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/customers/presentation/providers/customer_detail_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;
  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CustomerDetailProvider>().loadCustomer(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailProvider>(
      builder: (context, provider, child) {
        final customer = provider.customer;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
            title: const Text('Customer'),
            actions: [IconButton(icon: const Icon(Icons.edit), onPressed: customer == null ? null : () => _showEditDialog(provider))],
          ),
          body: Padding(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: customer == null
                ? (provider.isLoading ? const LoadingWidget() : const EmptyStateWidget(message: 'No data'))
                : Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${customer.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: AppConfig.smallPadding, width: double.infinity),
                            Text('Phone: ${customer.phone}'),
                            SizedBox(height: AppConfig.smallPadding, width: double.infinity),
                            Text('Active: ${customer.isActive ? 'Yes' : 'No'}'),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _showEditDialog(CustomerDetailProvider provider) {
    final nameController = TextEditingController(text: provider.customer?.name ?? '');
    final phoneController = TextEditingController(text: provider.customer?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        provider.setContext(ctx);
        return Dialog(
          child: Container(
            width: ctx.isDesktop ? 520 : 420,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('Edit Customer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave a field empty to keep it unchanged',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final ok = await provider.updateCustomer(
                                  id: provider.customer!.id,
                                  name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                                  phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                );
                                if (ok && mounted) Navigator.of(ctx).pop();
                              },
                        child: provider.isLoading ? const LoadingWidget(size: 20) : const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
