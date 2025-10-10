import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/services/bill_pdf_service.dart';

class BillPrintPreviewPage extends StatefulWidget {
  final String billId;

  const BillPrintPreviewPage({super.key, required this.billId});

  @override
  State<BillPrintPreviewPage> createState() => _BillPrintPreviewPageState();
}

class _BillPrintPreviewPageState extends State<BillPrintPreviewPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<BillProvider>();
    await provider.getBillByBillId(billId: widget.billId);
    await provider.getPaymentsByBillId(billId: widget.billId);
    await provider.getBillAdjustmentsByBillId(billId: widget.billId);
    // Ensure phone is fetched into cache for preview
    final bill = provider.currentBill;
    if (bill != null) {
      await provider.fetchCustomerPhone(bill.order.customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Preview')),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, _) {
          if (billProvider.isLoading || billProvider.currentBill == null) {
            return const LoadingWidget(message: 'Preparing bill...');
          }

          final bill = billProvider.currentBill!;
          final payments = billProvider.payments;
          final adjustments = billProvider.adjustments;
          final customerPhone = billProvider.getCustomerPhone(bill.order.customerId);

          return PdfPreview(
            pdfFileName: 'bill_${bill.id}.pdf',
            canChangeOrientation: true,
            canChangePageFormat: true,
            build: (format) async {
              final Uint8List bytes = await BillPdfService.buildBillPdf(
                bill: bill,
                payments: payments,
                adjustments: adjustments,
                cardImages: billProvider.cardImages,
                customerPhone: customerPhone,
              );
              return bytes;
            },
          );
        },
      ),
    );
  }
}
