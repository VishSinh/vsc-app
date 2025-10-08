import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';

class BillFilterDialog extends StatefulWidget {
  const BillFilterDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(context: context, builder: (ctx) => const BillFilterDialog());
  }

  @override
  State<BillFilterDialog> createState() => _BillFilterDialogState();
}

class _BillFilterDialogState extends State<BillFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  String _paidSelection = 'any'; // any | only | exclude
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    final provider = context.read<BillProvider>();
    _paidSelection = _triStateToString(provider.filterPaid);
    _sortBy = provider.sortBy;
    _sortOrder = provider.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bill Filters & Sorting'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _paidSelection,
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('--')),
                  DropdownMenuItem(value: 'only', child: Text('Only PAID')),
                  DropdownMenuItem(value: 'exclude', child: Text('Pending/Partial')),
                ],
                onChanged: (val) => setState(() => _paidSelection = val ?? 'any'),
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      items: const [DropdownMenuItem(value: 'created_at', child: Text('Sort by Created At'))],
                      onChanged: (val) => setState(() => _sortBy = val ?? 'created_at'),
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

  void _clearLocal() {
    setState(() {
      _paidSelection = 'any';
      _sortBy = 'created_at';
      _sortOrder = 'desc';
    });
  }

  void _apply() {
    final provider = context.read<BillProvider>();
    provider.setServerFilters(paid: _stringToTriState(_paidSelection), sortBy: _sortBy, sortOrder: _sortOrder);
    provider.getBills(page: 1);
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
