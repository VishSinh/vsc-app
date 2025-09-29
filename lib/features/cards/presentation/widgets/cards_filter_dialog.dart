import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_list_provider.dart';

enum _ValueFilterMode { none, eq, gt, gte, lt, lte, between }

class CardsFilterDialog extends StatefulWidget {
  const CardsFilterDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(context: context, builder: (ctx) => const CardsFilterDialog());
  }

  @override
  State<CardsFilterDialog> createState() => _CardsFilterDialogState();
}

class _CardsFilterDialogState extends State<CardsFilterDialog> {
  final _formKey = GlobalKey<FormState>();
  // quantity fields (smart)
  _ValueFilterMode _quantityMode = _ValueFilterMode.none;
  late final TextEditingController _quantityValueController;
  late final TextEditingController _quantityMinController;
  late final TextEditingController _quantityMaxController;
  // cost price fields (smart)
  _ValueFilterMode _costMode = _ValueFilterMode.none;
  late final TextEditingController _costValueController;
  late final TextEditingController _costMinController;
  late final TextEditingController _costMaxController;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    final provider = context.read<CardListProvider>();

    // Quantity init
    _quantityValueController = TextEditingController();
    _quantityMinController = TextEditingController();
    _quantityMaxController = TextEditingController();
    if (provider.filterQuantity != null) {
      _quantityMode = _ValueFilterMode.eq;
      _quantityValueController.text = provider.filterQuantity!.toString();
    } else if (provider.filterQuantityGte != null && provider.filterQuantityLte != null) {
      _quantityMode = _ValueFilterMode.between;
      _quantityMinController.text = provider.filterQuantityGte!.toString();
      _quantityMaxController.text = provider.filterQuantityLte!.toString();
    } else if (provider.filterQuantityGte != null) {
      _quantityMode = _ValueFilterMode.gte;
      _quantityValueController.text = provider.filterQuantityGte!.toString();
    } else if (provider.filterQuantityLte != null) {
      _quantityMode = _ValueFilterMode.lte;
      _quantityValueController.text = provider.filterQuantityLte!.toString();
    } else if (provider.filterQuantityGt != null) {
      _quantityMode = _ValueFilterMode.gt;
      _quantityValueController.text = provider.filterQuantityGt!.toString();
    } else if (provider.filterQuantityLt != null) {
      _quantityMode = _ValueFilterMode.lt;
      _quantityValueController.text = provider.filterQuantityLt!.toString();
    } else {
      _quantityMode = _ValueFilterMode.none;
    }

    // Cost init
    _costValueController = TextEditingController();
    _costMinController = TextEditingController();
    _costMaxController = TextEditingController();
    if (provider.filterCostPrice != null) {
      _costMode = _ValueFilterMode.eq;
      _costValueController.text = provider.filterCostPrice!.toString();
    } else if (provider.filterCostPriceGte != null && provider.filterCostPriceLte != null) {
      _costMode = _ValueFilterMode.between;
      _costMinController.text = provider.filterCostPriceGte!.toString();
      _costMaxController.text = provider.filterCostPriceLte!.toString();
    } else if (provider.filterCostPriceGte != null) {
      _costMode = _ValueFilterMode.gte;
      _costValueController.text = provider.filterCostPriceGte!.toString();
    } else if (provider.filterCostPriceLte != null) {
      _costMode = _ValueFilterMode.lte;
      _costValueController.text = provider.filterCostPriceLte!.toString();
    } else if (provider.filterCostPriceGt != null) {
      _costMode = _ValueFilterMode.gt;
      _costValueController.text = provider.filterCostPriceGt!.toString();
    } else if (provider.filterCostPriceLt != null) {
      _costMode = _ValueFilterMode.lt;
      _costValueController.text = provider.filterCostPriceLt!.toString();
    } else {
      _costMode = _ValueFilterMode.none;
    }

    _sortBy = provider.sortBy;
    _sortOrder = provider.sortOrder;
  }

  @override
  void dispose() {
    _quantityValueController.dispose();
    _quantityMinController.dispose();
    _quantityMaxController.dispose();
    _costValueController.dispose();
    _costMinController.dispose();
    _costMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters & Sorting'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Quantity', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<_ValueFilterMode>(
                value: _quantityMode,
                items: const [
                  DropdownMenuItem(value: _ValueFilterMode.none, child: Text('--')),
                  DropdownMenuItem(value: _ValueFilterMode.eq, child: Text('= (बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.gte, child: Text('≥ (से अधिक या बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.lte, child: Text('≤ (से कम या बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.gt, child: Text('> (से अधिक)')),
                  DropdownMenuItem(value: _ValueFilterMode.lt, child: Text('< (से कम)')),
                  DropdownMenuItem(value: _ValueFilterMode.between, child: Text('Between (के बीच)')),
                ],
                onChanged: (m) => setState(() => _quantityMode = m ?? _ValueFilterMode.none),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              if (_quantityMode == _ValueFilterMode.eq ||
                  _quantityMode == _ValueFilterMode.gte ||
                  _quantityMode == _ValueFilterMode.lte ||
                  _quantityMode == _ValueFilterMode.gt ||
                  _quantityMode == _ValueFilterMode.lt)
                _buildNumberField(_quantityValueController, 'Value')
              else if (_quantityMode == _ValueFilterMode.between)
                Row(
                  children: [
                    Expanded(child: _buildNumberField(_quantityMinController, 'Min')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildNumberField(_quantityMaxController, 'Max')),
                  ],
                ),

              const Divider(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Cost Price', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<_ValueFilterMode>(
                value: _costMode,
                items: const [
                  DropdownMenuItem(value: _ValueFilterMode.none, child: Text('--')),
                  DropdownMenuItem(value: _ValueFilterMode.eq, child: Text('= (बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.gte, child: Text('≥ (से अधिक या बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.lte, child: Text('≤ (से कम या बराबर)')),
                  DropdownMenuItem(value: _ValueFilterMode.gt, child: Text('> (से अधिक)')),
                  DropdownMenuItem(value: _ValueFilterMode.lt, child: Text('< (से कम)')),
                  DropdownMenuItem(value: _ValueFilterMode.between, child: Text('Between (के बीच)')),
                ],
                onChanged: (m) => setState(() => _costMode = m ?? _ValueFilterMode.none),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              if (_costMode == _ValueFilterMode.eq ||
                  _costMode == _ValueFilterMode.gte ||
                  _costMode == _ValueFilterMode.lte ||
                  _costMode == _ValueFilterMode.gt ||
                  _costMode == _ValueFilterMode.lt)
                _buildDecimalField(_costValueController, 'Value')
              else if (_costMode == _ValueFilterMode.between)
                Row(
                  children: [
                    Expanded(child: _buildDecimalField(_costMinController, 'Min')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDecimalField(_costMaxController, 'Max')),
                  ],
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'created_at', child: Text('Sort by Created At')),
                        DropdownMenuItem(value: 'cost_price', child: Text('Sort by Cost Price')),
                        DropdownMenuItem(value: 'quantity', child: Text('Sort by Quantity')),
                      ],
                      onChanged: (val) => setState(() => _sortBy = val ?? 'created_at'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortOrder,
                      items: const [
                        DropdownMenuItem(value: 'asc', child: Text('Ascending (छोटा से बड़ा)')),
                        DropdownMenuItem(value: 'desc', child: Text('Descending (बड़ा से छोटा)')),
                      ],
                      onChanged: (val) => setState(() => _sortOrder = val ?? 'desc'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _quantityValueController.clear();
            _quantityMinController.clear();
            _quantityMaxController.clear();
            _costValueController.clear();
            _costMinController.clear();
            _costMaxController.clear();
            setState(() {
              _quantityMode = _ValueFilterMode.none;
              _costMode = _ValueFilterMode.none;
              _sortBy = 'created_at';
              _sortOrder = 'desc';
            });
          },
          child: const Text('Clear'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDecimalField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  void _apply() {
    final provider = context.read<CardListProvider>();

    int? parseInt(TextEditingController c) => c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());
    double? parseDouble(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());

    // Map quantity mode to params
    int? qEq;
    int? qGt;
    int? qGte;
    int? qLt;
    int? qLte;
    switch (_quantityMode) {
      case _ValueFilterMode.eq:
        qEq = parseInt(_quantityValueController);
        break;
      case _ValueFilterMode.gt:
        qGt = parseInt(_quantityValueController);
        break;
      case _ValueFilterMode.gte:
        qGte = parseInt(_quantityValueController);
        break;
      case _ValueFilterMode.lt:
        qLt = parseInt(_quantityValueController);
        break;
      case _ValueFilterMode.lte:
        qLte = parseInt(_quantityValueController);
        break;
      case _ValueFilterMode.between:
        qGte = parseInt(_quantityMinController);
        qLte = parseInt(_quantityMaxController);
        break;
      case _ValueFilterMode.none:
        break;
    }

    // Map cost mode to params
    double? cEq;
    double? cGt;
    double? cGte;
    double? cLt;
    double? cLte;
    switch (_costMode) {
      case _ValueFilterMode.eq:
        cEq = parseDouble(_costValueController);
        break;
      case _ValueFilterMode.gt:
        cGt = parseDouble(_costValueController);
        break;
      case _ValueFilterMode.gte:
        cGte = parseDouble(_costValueController);
        break;
      case _ValueFilterMode.lt:
        cLt = parseDouble(_costValueController);
        break;
      case _ValueFilterMode.lte:
        cLte = parseDouble(_costValueController);
        break;
      case _ValueFilterMode.between:
        cGte = parseDouble(_costMinController);
        cLte = parseDouble(_costMaxController);
        break;
      case _ValueFilterMode.none:
        break;
    }

    provider.setServerFilters(
      quantity: qEq,
      quantityGt: qGt,
      quantityGte: qGte,
      quantityLt: qLt,
      quantityLte: qLte,
      costPrice: cEq,
      costPriceGt: cGt,
      costPriceGte: cGte,
      costPriceLt: cLt,
      costPriceLte: cLte,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    // Reload from first page with new filters
    provider.loadCards(page: 1);
    Navigator.of(context).pop();
  }
}
