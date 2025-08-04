import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/box_order_edit_form_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

class BoxOrderEditDialog extends StatelessWidget {
  final String boxOrderId;
  final String currentBoxMakerId;
  final String currentTotalBoxCost;
  final String currentTotalBoxExpense;
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
    required this.currentTotalBoxExpense,
    required this.currentBoxStatus,
    required this.currentBoxType,
    required this.currentBoxQuantity,
    this.currentEstimatedCompletion,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = BoxOrderEditFormProvider();
        provider.initializeForm(
          currentBoxMakerId: currentBoxMakerId,
          currentTotalBoxCost: currentTotalBoxCost,
          currentTotalBoxExpense: currentTotalBoxExpense,
          currentBoxStatus: currentBoxStatus,
          currentBoxType: currentBoxType,
          currentBoxQuantity: currentBoxQuantity,
          currentEstimatedCompletion: currentEstimatedCompletion,
        );
        return provider;
      },
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final orderProvider = context.read<OrderListProvider>();
            orderProvider.setContext(context);
            orderProvider.fetchBoxMakers();
          });

          return Consumer2<BoxOrderEditFormProvider, OrderListProvider>(
            builder: (context, formProvider, orderProvider, child) {
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
                        child: Column(
                          children: [
                            _buildBoxMakerSection(context, formProvider, orderProvider),
                            const SizedBox(height: 16),
                            _buildBoxStatusSection(context, formProvider),
                            const SizedBox(height: 16),
                            _buildBoxTypeSection(context, formProvider),
                            const SizedBox(height: 16),
                            _buildTotalBoxCostSection(context, formProvider),
                            const SizedBox(height: 16),
                            _buildTotalBoxExpenseSection(context, formProvider),
                            const SizedBox(height: 16),
                            _buildBoxQuantitySection(context, formProvider),
                            const SizedBox(height: 16),
                            _buildEstimatedCompletionSection(context, formProvider),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, formProvider, orderProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBoxMakerSection(BuildContext context, BoxOrderEditFormProvider formProvider, OrderListProvider orderProvider) {
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
              value: formProvider.formModel.currentBoxMakerId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.boxMakers.map((maker) => DropdownMenuItem<String>(value: maker.id, child: Text(maker.name))),
              ],
              onChanged: (value) {
                formProvider.updateBoxMakerId(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoxStatusSection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<BoxStatus>(
          decoration: const InputDecoration(labelText: 'Box Status', border: OutlineInputBorder(), hintText: 'Select status'),
          value: formProvider.formModel.currentBoxStatus,
          items: BoxStatus.values.map((status) => DropdownMenuItem<BoxStatus>(value: status, child: Text(_formatBoxStatus(status)))).toList(),
          onChanged: (value) {
            formProvider.updateBoxStatus(value);
          },
        ),
      ],
    );
  }

  Widget _buildBoxTypeSection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<OrderBoxType>(
          decoration: const InputDecoration(labelText: 'Box Type', border: OutlineInputBorder(), hintText: 'Select box type'),
          value: formProvider.formModel.currentBoxType,
          items: OrderBoxType.values.map((type) => DropdownMenuItem<OrderBoxType>(value: type, child: Text(_formatBoxType(type)))).toList(),
          onChanged: (value) {
            formProvider.updateBoxType(value);
          },
        ),
      ],
    );
  }

  Widget _buildTotalBoxCostSection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.totalBoxCostController,
          decoration: const InputDecoration(labelText: 'Total Box Cost', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateTotalBoxCost(value);
          },
        ),
      ],
    );
  }

  Widget _buildTotalBoxExpenseSection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.totalBoxExpenseController,
          decoration: const InputDecoration(labelText: 'Total Box Expense', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateTotalBoxExpense(value);
          },
        ),
      ],
    );
  }

  Widget _buildBoxQuantitySection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.boxQuantityController,
          decoration: const InputDecoration(labelText: 'Box Quantity', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateBoxQuantity(value);
          },
        ),
      ],
    );
  }

  Widget _buildEstimatedCompletionSection(BuildContext context, BoxOrderEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: formProvider.formModel.currentEstimatedCompletion ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (time != null) {
                formProvider.updateEstimatedCompletion(date, time);
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Estimated Completion',
              border: const OutlineInputBorder(),
              hintText: formProvider.formModel.currentEstimatedCompletion != null
                  ? '${formProvider.formModel.currentEstimatedCompletion!.day}/${formProvider.formModel.currentEstimatedCompletion!.month}/${formProvider.formModel.currentEstimatedCompletion!.year} ${formProvider.formModel.currentEstimatedCompletion!.hour}:${formProvider.formModel.currentEstimatedCompletion!.minute.toString().padLeft(2, '0')}'
                  : 'Select date and time',
            ),
            child: Text(
              formProvider.formModel.currentEstimatedCompletion != null
                  ? '${formProvider.formModel.currentEstimatedCompletion!.day}/${formProvider.formModel.currentEstimatedCompletion!.month}/${formProvider.formModel.currentEstimatedCompletion!.year} ${formProvider.formModel.currentEstimatedCompletion!.hour}:${formProvider.formModel.currentEstimatedCompletion!.minute.toString().padLeft(2, '0')}'
                  : 'Select date and time',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, BoxOrderEditFormProvider formProvider, OrderListProvider orderProvider) {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: provider.isUpdatingBoxOrder ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: provider.isUpdatingBoxOrder ? null : () => _handleSubmit(context, formProvider.formModel),
              child: provider.isUpdatingBoxOrder
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, BoxOrderUpdateFormModel formModel) async {
    if (!formModel.hasChanges) {
      SnackbarUtils.showWarning(context, 'No changes made');
      return;
    }

    final provider = context.read<OrderListProvider>();
    await provider.updateBoxOrder(boxOrderId: boxOrderId, formModel: formModel);

    // ✅ Success/error handling is now automatic via executeApiOperation
    // If we reach here without error, it was successful
    onSuccess();
    Navigator.of(context).pop();
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
