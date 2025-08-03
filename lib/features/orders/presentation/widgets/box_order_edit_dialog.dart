import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

class BoxOrderEditDialog extends StatefulWidget {
  final String boxOrderId;
  final String currentBoxMakerId;
  final String currentTotalBoxCost;
  final String currentBoxStatus;
  final String currentBoxType;
  final int currentBoxQuantity;
  final String? currentEstimatedCompletion;
  final VoidCallback onSuccess;

  const BoxOrderEditDialog({
    super.key,
    required this.boxOrderId,
    required this.currentBoxMakerId,
    required this.currentTotalBoxCost,
    required this.currentBoxStatus,
    required this.currentBoxType,
    required this.currentBoxQuantity,
    this.currentEstimatedCompletion,
    required this.onSuccess,
  });

  @override
  State<BoxOrderEditDialog> createState() => _BoxOrderEditDialogState();
}

class _BoxOrderEditDialogState extends State<BoxOrderEditDialog> {
  late BoxOrderUpdateFormModel _formModel;
  final _formKey = GlobalKey<FormState>();
  final _totalBoxCostController = TextEditingController();
  final _boxQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formModel = BoxOrderUpdateFormModel.fromCurrentData(
      boxMakerId: widget.currentBoxMakerId.isNotEmpty ? widget.currentBoxMakerId : null,
      totalBoxCost: widget.currentTotalBoxCost,
      boxStatus: widget.currentBoxStatus,
      boxType: widget.currentBoxType,
      boxQuantity: widget.currentBoxQuantity,
      estimatedCompletion: widget.currentEstimatedCompletion,
    );

    // Populate current values with original values
    _formModel.currentBoxMakerId = _formModel.boxMakerId;
    _formModel.currentTotalBoxCost = _formModel.totalBoxCost;
    _formModel.currentBoxStatus = _formModel.boxStatus;
    _formModel.currentBoxType = _formModel.boxType;
    _formModel.currentBoxQuantity = _formModel.boxQuantity;
    _formModel.currentEstimatedCompletion = _formModel.estimatedCompletion;

    // Set initial text for text controllers
    _totalBoxCostController.text = _formModel.currentTotalBoxCost ?? '';
    _boxQuantityController.text = _formModel.currentBoxQuantity?.toString() ?? '';

    // Fetch box makers when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderListProvider>().fetchBoxMakers();
    });
  }

  @override
  void dispose() {
    _totalBoxCostController.dispose();
    _boxQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Edit Box Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildBoxMakerSection(),
                  const SizedBox(height: 16),
                  _buildBoxStatusSection(),
                  const SizedBox(height: 16),
                  _buildBoxTypeSection(),
                  const SizedBox(height: 16),
                  _buildTotalBoxCostSection(),
                  const SizedBox(height: 16),
                  _buildBoxQuantitySection(),
                  const SizedBox(height: 16),
                  _buildEstimatedCompletionSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxMakerSection() {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBoxMakers) {
          return const CircularProgressIndicator();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Box Maker', border: OutlineInputBorder(), hintText: 'Select a box maker'),
              value: _formModel.currentBoxMakerId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.boxMakers.map((maker) => DropdownMenuItem<String>(value: maker.id, child: Text(maker.name))),
              ],
              onChanged: (value) {
                setState(() {
                  _formModel.currentBoxMakerId = value;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoxStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<BoxStatus>(
          decoration: const InputDecoration(labelText: 'Box Status', border: OutlineInputBorder(), hintText: 'Select status'),
          value: _formModel.currentBoxStatus,
          items: BoxStatus.values.map((status) => DropdownMenuItem<BoxStatus>(value: status, child: Text(_formatBoxStatus(status)))).toList(),
          onChanged: (value) {
            setState(() {
              _formModel.currentBoxStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBoxTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<OrderBoxType>(
          decoration: const InputDecoration(labelText: 'Box Type', border: OutlineInputBorder(), hintText: 'Select box type'),
          value: _formModel.currentBoxType,
          items: OrderBoxType.values.map((type) => DropdownMenuItem<OrderBoxType>(value: type, child: Text(_formatBoxType(type)))).toList(),
          onChanged: (value) {
            setState(() {
              _formModel.currentBoxType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTotalBoxCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _totalBoxCostController,
          decoration: const InputDecoration(labelText: 'Total Box Cost', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _formModel.currentTotalBoxCost = value.isNotEmpty ? value : null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBoxQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _boxQuantityController,
          decoration: const InputDecoration(labelText: 'Box Quantity', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _formModel.currentBoxQuantity = int.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildEstimatedCompletionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _formModel.currentEstimatedCompletion ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (time != null) {
                setState(() {
                  _formModel.currentEstimatedCompletion = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                });
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Estimated Completion',
              border: const OutlineInputBorder(),
              hintText: _formModel.currentEstimatedCompletion != null
                  ? '${_formModel.currentEstimatedCompletion!.day}/${_formModel.currentEstimatedCompletion!.month}/${_formModel.currentEstimatedCompletion!.year} ${_formModel.currentEstimatedCompletion!.hour}:${_formModel.currentEstimatedCompletion!.minute.toString().padLeft(2, '0')}'
                  : 'Select date and time',
            ),
            child: Text(
              _formModel.currentEstimatedCompletion != null
                  ? '${_formModel.currentEstimatedCompletion!.day}/${_formModel.currentEstimatedCompletion!.month}/${_formModel.currentEstimatedCompletion!.year} ${_formModel.currentEstimatedCompletion!.hour}:${_formModel.currentEstimatedCompletion!.minute.toString().padLeft(2, '0')}'
                  : 'Select date and time',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: provider.isUpdatingBoxOrder ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: provider.isUpdatingBoxOrder ? null : _handleSubmit,
              child: provider.isUpdatingBoxOrder
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formModel.hasChanges) {
      SnackbarUtils.showWarning(context, 'No changes made');
      return;
    }

    final provider = context.read<OrderListProvider>();
    await provider.updateBoxOrder(boxOrderId: widget.boxOrderId, formModel: _formModel);

    if (provider.successMessage != null) {
      SnackbarUtils.showSuccess(context, provider.successMessage!);
      widget.onSuccess();
      Navigator.of(context).pop();
    } else if (provider.errorMessage != null) {
      SnackbarUtils.showError(context, provider.errorMessage!);
    }
  }

  String _formatBoxStatus(BoxStatus status) {
    switch (status) {
      case BoxStatus.pending:
        return 'Pending';
      case BoxStatus.inProgress:
        return 'In Progress';
      case BoxStatus.completed:
        return 'Completed';
    }
  }

  String _formatBoxType(OrderBoxType type) {
    switch (type) {
      case OrderBoxType.folding:
        return 'Folding';
      case OrderBoxType.complete:
        return 'Complete';
    }
  }
}
