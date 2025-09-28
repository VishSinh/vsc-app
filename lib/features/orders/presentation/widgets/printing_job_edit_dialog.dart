import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/enums/printing_status.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/printing_job_edit_form_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

class PrintingJobEditDialog extends StatelessWidget {
  final String printingJobId;
  final String currentPrinterId;
  final String currentTracingStudioId;
  final String currentTotalPrintingCost;
  final String currentTotalPrintingExpense;
  final String currentTotalTracingExpense;
  final String currentPrintingStatus;
  final int currentPrintQuantity;
  final String? currentEstimatedCompletion;
  final VoidCallback onSuccess;

  const PrintingJobEditDialog({
    super.key,
    required this.printingJobId,
    required this.currentPrinterId,
    required this.currentTracingStudioId,
    required this.currentTotalPrintingCost,
    required this.currentTotalPrintingExpense,
    required this.currentTotalTracingExpense,
    required this.currentPrintingStatus,
    required this.currentPrintQuantity,
    this.currentEstimatedCompletion,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = PrintingJobEditFormProvider();
        provider.initializeForm(
          currentPrinterId: currentPrinterId,
          currentTracingStudioId: currentTracingStudioId,
          currentTotalPrintingCost: currentTotalPrintingCost,
          currentTotalPrintingExpense: currentTotalPrintingExpense,
          currentTotalTracingExpense: currentTotalTracingExpense,
          currentPrintingStatus: currentPrintingStatus,
          currentPrintQuantity: currentPrintQuantity,
          currentEstimatedCompletion: currentEstimatedCompletion,
        );
        return provider;
      },
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final orderProvider = context.read<OrderListProvider>();
            orderProvider.setContext(context);
            orderProvider.fetchPrinters();
            orderProvider.fetchTracingStudios();
          });

          return Consumer2<PrintingJobEditFormProvider, OrderListProvider>(
            builder: (context, formProvider, orderProvider, child) => Dialog(
              child: Container(
                width: context.isDesktop ? 800 : 500,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                          const Text('Edit Printing Job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pair Printer & Tracing Studio on desktop
                                if (context.isDesktop)
                                  Row(
                                    children: [
                                      Expanded(child: _buildPrinterSection(context, formProvider, orderProvider)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildTracingStudioSection(context, formProvider, orderProvider)),
                                    ],
                                  )
                                else ...[
                                  _buildPrinterSection(context, formProvider, orderProvider),
                                  const SizedBox(height: 16),
                                  _buildTracingStudioSection(context, formProvider, orderProvider),
                                ],
                                const SizedBox(height: 16),
                                _buildPrintingStatusSection(context, formProvider),
                                const SizedBox(height: 16),
                                _buildTotalPrintingCostSection(context, formProvider),
                                const SizedBox(height: 16),
                                // Pair Printing Expense & Tracing Expense on desktop
                                if (context.isDesktop)
                                  Row(
                                    children: [
                                      Expanded(child: _buildTotalPrintingExpenseSection(context, formProvider)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildTotalTracingExpenseSection(context, formProvider)),
                                    ],
                                  )
                                else ...[
                                  _buildTotalPrintingExpenseSection(context, formProvider),
                                  const SizedBox(height: 16),
                                  _buildTotalTracingExpenseSection(context, formProvider),
                                ],
                                const SizedBox(height: 16),
                                _buildPrintQuantitySection(context, formProvider),
                                const SizedBox(height: 16),
                                _buildEstimatedCompletionSection(context, formProvider),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(padding: const EdgeInsets.all(16), child: _buildActionButtons(context, formProvider, orderProvider)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrinterSection(BuildContext context, PrintingJobEditFormProvider formProvider, OrderListProvider orderProvider) {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPrinters) {
          return const LoadingWidget(size: 24);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Printer',
                border: const OutlineInputBorder(),
                hintText: 'Select a printer',
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.withOpacity(0.6))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
              ),
              value: formProvider.formModel.currentPrinterId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.printers.map((printer) => DropdownMenuItem<String>(value: printer.id, child: Text(printer.name))),
              ],
              onChanged: (value) {
                formProvider.updatePrinterId(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTracingStudioSection(BuildContext context, PrintingJobEditFormProvider formProvider, OrderListProvider orderProvider) {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTracingStudios) {
          return const LoadingWidget(size: 24);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tracing Studio',
                border: const OutlineInputBorder(),
                hintText: 'Select a tracing studio',
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.withOpacity(0.6))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
              ),
              value: formProvider.formModel.currentTracingStudioId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.tracingStudios.map((studio) => DropdownMenuItem<String>(value: studio.id, child: Text(studio.name))),
              ],
              onChanged: (value) {
                formProvider.updateTracingStudioId(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrintingStatusSection(BuildContext context, PrintingJobEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<PrintingStatus>(
          decoration: const InputDecoration(labelText: 'Printing Status', border: OutlineInputBorder(), hintText: 'Select status'),
          value: formProvider.formModel.currentPrintingStatus,
          items: PrintingStatus.values
              .map((status) => DropdownMenuItem<PrintingStatus>(value: status, child: Text(_formatPrintingStatus(status))))
              .toList(),
          onChanged: (value) {
            formProvider.updatePrintingStatus(value);
          },
        ),
      ],
    );
  }

  Widget _buildTotalPrintingCostSection(BuildContext context, PrintingJobEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.totalPrintingCostController,
          decoration: const InputDecoration(labelText: 'Total Printing Cost', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateTotalPrintingCost(value);
          },
        ),
      ],
    );
  }

  Widget _buildTotalPrintingExpenseSection(BuildContext context, PrintingJobEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.totalPrintingExpenseController,
          decoration: InputDecoration(
            labelText: 'Total Printing Expense',
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.withOpacity(0.6))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateTotalPrintingExpense(value);
          },
        ),
      ],
    );
  }

  Widget _buildTotalTracingExpenseSection(BuildContext context, PrintingJobEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.totalTracingExpenseController,
          decoration: InputDecoration(
            labelText: 'Total Tracing Expense',
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.withOpacity(0.6))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updateTotalTracingExpense(value);
          },
        ),
      ],
    );
  }

  Widget _buildPrintQuantitySection(BuildContext context, PrintingJobEditFormProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: formProvider.printQuantityController,
          decoration: const InputDecoration(labelText: 'Print Quantity', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formProvider.updatePrintQuantity(value);
          },
        ),
      ],
    );
  }

  Widget _buildEstimatedCompletionSection(BuildContext context, PrintingJobEditFormProvider formProvider) {
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

  Widget _buildActionButtons(BuildContext context, PrintingJobEditFormProvider formProvider, OrderListProvider orderProvider) {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: provider.isUpdatingPrintingJob ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: provider.isUpdatingPrintingJob ? null : () => _handleSubmit(context, formProvider.formModel),
              child: provider.isUpdatingPrintingJob ? const LoadingWidget(size: 20) : const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, PrintingJobUpdateFormModel formModel) async {
    if (!formModel.hasChanges) {
      SnackbarUtils.showWarning(context, 'No changes made');
      return;
    }

    final provider = context.read<OrderListProvider>();
    await provider.updatePrintingJob(printingJobId: printingJobId, formModel: formModel);

    // ✅ Success/error handling is now automatic via executeApiOperation
    // If we reach here without error, it was successful
    onSuccess();
    Navigator.of(context).pop();
  }

  String _formatPrintingStatus(PrintingStatus status) {
    switch (status) {
      case PrintingStatus.pending:
        return 'Pending';
      case PrintingStatus.inTracing:
        return 'In Tracing';
      case PrintingStatus.inPrinting:
        return 'In Printing';
      case PrintingStatus.completed:
        return 'Completed';
    }
  }
}
