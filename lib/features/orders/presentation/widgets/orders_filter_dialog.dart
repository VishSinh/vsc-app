import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';

enum _DateFilterMode { none, exact, range }

class OrdersFilterDialog extends StatefulWidget {
  const OrdersFilterDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(context: context, builder: (ctx) => const OrdersFilterDialog());
  }

  @override
  State<OrdersFilterDialog> createState() => _OrdersFilterDialogState();
}

class _OrdersFilterDialogState extends State<OrdersFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  // Delivered/Fully Paid filter: null = any, true = only delivered/fully paid, false = exclude
  bool? _deliveredOrPaid;

  // Date filtering
  _DateFilterMode _dateMode = _DateFilterMode.none;
  DateTime? _exactDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  late final TextEditingController _exactDateController;
  late final TextEditingController _fromDateController;
  late final TextEditingController _toDateController;

  String _sortBy = 'order_date';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderListProvider>();

    _deliveredOrPaid = provider.filterDeliveredOrPaid;

    _exactDateController = TextEditingController();
    _fromDateController = TextEditingController();
    _toDateController = TextEditingController();

    if (provider.filterOrderDate != null) {
      _dateMode = _DateFilterMode.exact;
      _exactDate = provider.filterOrderDate;
      _exactDateController.text = DateFormatter.formatDate(provider.filterOrderDate!);
    } else if (provider.filterOrderDateGte != null || provider.filterOrderDateLte != null) {
      _dateMode = _DateFilterMode.range;
      _fromDate = provider.filterOrderDateGte;
      _toDate = provider.filterOrderDateLte;
      if (_fromDate != null) _fromDateController.text = DateFormatter.formatDate(_fromDate!);
      if (_toDate != null) _toDateController.text = DateFormatter.formatDate(_toDate!);
    } else {
      _dateMode = _DateFilterMode.none;
    }

    _sortBy = provider.sortBy;
    _sortOrder = provider.sortOrder;
  }

  @override
  void dispose() {
    _exactDateController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Order Filters & Sorting'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Delivery / Payment Status', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _triStateToString(_deliveredOrPaid),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('--')),
                  DropdownMenuItem(value: 'only', child: Text('Delivered / Fully Paid')),
                  DropdownMenuItem(value: 'exclude', child: Text('Pending Orders')),
                ],
                onChanged: (val) => setState(() => _deliveredOrPaid = _stringToTriState(val)),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Order Date', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<_DateFilterMode>(
                value: _dateMode,
                items: const [
                  DropdownMenuItem(value: _DateFilterMode.none, child: Text('--')),
                  DropdownMenuItem(value: _DateFilterMode.exact, child: Text('Exact Date')),
                  DropdownMenuItem(value: _DateFilterMode.range, child: Text('Between Dates')),
                ],
                onChanged: (m) => setState(() => _dateMode = m ?? _DateFilterMode.none),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              if (_dateMode == _DateFilterMode.exact)
                _buildDateField(controller: _exactDateController, label: 'Date', onPick: (d) => setState(() => _exactDate = d))
              else if (_dateMode == _DateFilterMode.range)
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        controller: _fromDateController,
                        label: 'From',
                        onPick: (d) => setState(() => _fromDate = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(controller: _toDateController, label: 'To', onPick: (d) => setState(() => _toDate = d)),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      items: const [DropdownMenuItem(value: 'order_date', child: Text('Sort by Order Date'))],
                      onChanged: (val) => setState(() => _sortBy = val ?? 'order_date'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortOrder,
                      items: const [
                        DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                        DropdownMenuItem(value: 'desc', child: Text('Descending')),
                      ],
                      onChanged: (val) => setState(() => _sortOrder = val ?? 'desc'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _clearLocal, child: const Text('Clear')),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String label, required ValueChanged<DateTime?> onPick}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (picked != null) {
          controller.text = DateFormatter.formatDate(picked);
          onPick(picked);
        } else {
          controller.clear();
          onPick(null);
        }
      },
    );
  }

  void _clearLocal() {
    setState(() {
      _deliveredOrPaid = null;
      _dateMode = _DateFilterMode.none;
      _exactDate = null;
      _fromDate = null;
      _toDate = null;
      _exactDateController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _sortBy = 'order_date';
      _sortOrder = 'desc';
    });
  }

  void _apply() {
    final provider = context.read<OrderListProvider>();

    DateTime? exact;
    DateTime? gte;
    DateTime? lte;
    switch (_dateMode) {
      case _DateFilterMode.none:
        break;
      case _DateFilterMode.exact:
        exact = _exactDate;
        break;
      case _DateFilterMode.range:
        gte = _fromDate;
        lte = _toDate;
        break;
    }

    provider.setServerFilters(
      deliveredOrPaid: _deliveredOrPaid,
      orderDate: exact,
      orderDateGte: gte,
      orderDateLte: lte,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    provider.fetchOrders(page: 1);
    Navigator.of(context).pop();
  }

  String _triStateToString(bool? v) {
    if (v == null) return 'any';
    return v ? 'only' : 'exclude';
  }

  bool? _stringToTriState(String? s) {
    switch (s) {
      case 'only':
        return true;
      case 'exclude':
        return false;
      case 'any':
      default:
        return null;
    }
  }
}
