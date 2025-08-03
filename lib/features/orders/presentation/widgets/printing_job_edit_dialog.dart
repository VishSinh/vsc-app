import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/enums/printing_status.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

class PrintingJobEditDialog extends StatefulWidget {
  final String printingJobId;
  final String currentPrinterId;
  final String currentTracingStudioId;
  final String currentTotalPrintingCost;
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
    required this.currentPrintingStatus,
    required this.currentPrintQuantity,
    this.currentEstimatedCompletion,
    required this.onSuccess,
  });

  @override
  State<PrintingJobEditDialog> createState() => _PrintingJobEditDialogState();
}

class _PrintingJobEditDialogState extends State<PrintingJobEditDialog> {
  late PrintingJobUpdateFormModel _formModel;
  final _formKey = GlobalKey<FormState>();
  final _totalPrintingCostController = TextEditingController();
  final _printQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formModel = PrintingJobUpdateFormModel.fromCurrentData(
      printerId: widget.currentPrinterId.isNotEmpty ? widget.currentPrinterId : null,
      tracingStudioId: widget.currentTracingStudioId.isNotEmpty ? widget.currentTracingStudioId : null,
      totalPrintingCost: widget.currentTotalPrintingCost,
      printingStatus: widget.currentPrintingStatus,
      printQuantity: widget.currentPrintQuantity,
      estimatedCompletion: widget.currentEstimatedCompletion,
    );

    // Populate current values with original values
    _formModel.currentPrinterId = _formModel.printerId;
    _formModel.currentTracingStudioId = _formModel.tracingStudioId;
    _formModel.currentTotalPrintingCost = _formModel.totalPrintingCost;
    _formModel.currentPrintingStatus = _formModel.printingStatus;
    _formModel.currentPrintQuantity = _formModel.printQuantity;
    _formModel.currentEstimatedCompletion = _formModel.estimatedCompletion;

    // Set initial text for text controllers
    _totalPrintingCostController.text = _formModel.currentTotalPrintingCost ?? '';
    _printQuantityController.text = _formModel.currentPrintQuantity?.toString() ?? '';

    // Fetch printers and tracing studios when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderListProvider>().fetchPrinters();
      context.read<OrderListProvider>().fetchTracingStudios();
    });
  }

  @override
  void dispose() {
    _totalPrintingCostController.dispose();
    _printQuantityController.dispose();
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
                const Icon(Icons.print, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Edit Printing Job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPrinterSection(),
                  const SizedBox(height: 16),
                  _buildTracingStudioSection(),
                  const SizedBox(height: 16),
                  _buildPrintingStatusSection(),
                  const SizedBox(height: 16),
                  _buildTotalPrintingCostSection(),
                  const SizedBox(height: 16),
                  _buildPrintQuantitySection(),
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

  Widget _buildPrinterSection() {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPrinters) {
          return const CircularProgressIndicator();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Printer', border: OutlineInputBorder(), hintText: 'Select a printer'),
              value: _formModel.currentPrinterId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.printers.map((printer) => DropdownMenuItem<String>(value: printer.id, child: Text(printer.name))),
              ],
              onChanged: (value) {
                setState(() {
                  _formModel.currentPrinterId = value;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTracingStudioSection() {
    return Consumer<OrderListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTracingStudios) {
          return const CircularProgressIndicator();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tracing Studio', border: OutlineInputBorder(), hintText: 'Select a tracing studio'),
              value: _formModel.currentTracingStudioId,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('--')),
                ...provider.tracingStudios.map((studio) => DropdownMenuItem<String>(value: studio.id, child: Text(studio.name))),
              ],
              onChanged: (value) {
                setState(() {
                  _formModel.currentTracingStudioId = value;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrintingStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<PrintingStatus>(
          decoration: const InputDecoration(labelText: 'Printing Status', border: OutlineInputBorder(), hintText: 'Select status'),
          value: _formModel.currentPrintingStatus,
          items: PrintingStatus.values
              .map((status) => DropdownMenuItem<PrintingStatus>(value: status, child: Text(_formatPrintingStatus(status))))
              .toList(),
          onChanged: (value) {
            setState(() {
              _formModel.currentPrintingStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTotalPrintingCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _totalPrintingCostController,
          decoration: const InputDecoration(labelText: 'Total Printing Cost', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _formModel.currentTotalPrintingCost = value.isNotEmpty ? value : null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrintQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _printQuantityController,
          decoration: const InputDecoration(labelText: 'Print Quantity', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _formModel.currentPrintQuantity = int.tryParse(value);
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
            TextButton(onPressed: provider.isUpdatingPrintingJob ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: provider.isUpdatingPrintingJob ? null : _handleSubmit,
              child: provider.isUpdatingPrintingJob
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
    await provider.updatePrintingJob(printingJobId: widget.printingJobId, formModel: _formModel);

    if (provider.successMessage != null) {
      SnackbarUtils.showSuccess(context, provider.successMessage!);
      widget.onSuccess();
      Navigator.of(context).pop();
    } else if (provider.errorMessage != null) {
      SnackbarUtils.showError(context, provider.errorMessage!);
    }
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
