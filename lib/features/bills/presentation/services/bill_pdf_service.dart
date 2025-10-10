import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_card_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_adjustment_view_model.dart';
import 'package:vsc_app/core/enums/bill_adjustment_type.dart';
import 'package:vsc_app/core/enums/bill_status.dart';
import 'package:vsc_app/core/enums/service_type.dart';

class BillPdfService {
  static Future<Uint8List> buildBillPdf({
    required BillViewModel bill,
    required List<PaymentViewModel> payments,
    required List<BillAdjustmentViewModel> adjustments,
    required Map<String, BillCardViewModel> cardImages,
    String? customerPhone,
  }) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ');
    final baseText = pw.TextStyle(fontSize: 9);
    final smallMuted = pw.TextStyle(fontSize: 8, color: PdfColors.grey700);

    pw.Widget sectionTitle(String text) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
    );

    pw.Widget keyValue(String key, String value) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 80, child: pw.Text(key, style: smallMuted)),
        pw.Expanded(child: pw.Text(value, style: baseText)),
      ],
    );

    String formatDate(DateTime dt) => DateFormat('dd/MM/yyyy HH:mm').format(dt);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12),
        build: (context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('VSC', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text('Call: 9334651144', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                  pw.Text('Whatsapp: 7004369180', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                ],
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          keyValue('Order', bill.orderName),
                          keyValue('Customer Phone', (customerPhone ?? '').isEmpty ? '-' : (customerPhone ?? '')),
                        ],
                      ),
                    ),
                    // pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          keyValue('Order Date', formatDate(bill.order.orderDate)),
                          keyValue('Staff', bill.order.staffName),
                          if (bill.order.specialInstruction.isNotEmpty)
                            keyValue('Special Instructions', bill.order.specialInstruction),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(color: PdfColors.blue, borderRadius: pw.BorderRadius.circular(10)),
                child: pw.Text(
                  bill.paymentStatus.getDisplayText(),
                  style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),

          // Items
          sectionTitle('Card Items'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
            columnWidths: {
              0: const pw.FlexColumnWidth(4), // Barcode
              1: const pw.FlexColumnWidth(1.5), // Qty
              2: const pw.FlexColumnWidth(2.0), // Box
              3: const pw.FlexColumnWidth(2.0), // Printing
              4: const pw.FlexColumnWidth(2.5), // Card Total
              5: const pw.FlexColumnWidth(2.5), // Line Total
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Barcode', style: baseText),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Qty', style: baseText),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Box', style: baseText),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Printing', style: baseText),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Card Total', style: baseText),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text('Line Total', style: baseText),
                  ),
                ],
              ),
              ...bill.order.orderItems.map((item) {
                final barcode = cardImages[item.cardId]?.barcode ?? '-';
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(barcode, style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(item.quantity.toString(), style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(currency.format(item.calculatedCosts.boxCost), style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(currency.format(item.calculatedCosts.printingCost), style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(currency.format(item.calculatedCosts.baseCost), style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(currency.format(item.calculatedCosts.totalCost), style: baseText),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 6),

          // Services
          if (bill.order.serviceItems.isNotEmpty) ...[
            sectionTitle('Service Items'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
              columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(3)},
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text('Type', style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text('Qty', style: baseText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text('Total', style: baseText),
                    ),
                  ],
                ),
                ...bill.order.serviceItems.map(
                  (svc) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(svc.serviceType?.displayText ?? svc.serviceTypeRaw, style: baseText),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(svc.quantity.toString(), style: baseText),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(currency.format(double.tryParse(svc.totalCost) ?? 0), style: baseText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
          ],

          // Payments + Adjustments (side-by-side when adjustments exist)
          ...(() {
            pw.Widget paymentsSection() {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  sectionTitle('Payments'),
                  if (payments.isEmpty)
                    pw.Text('No payments made yet', style: smallMuted)
                  else
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
                      columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(3)},
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Mode', style: baseText),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Amount', style: baseText),
                            ),
                          ],
                        ),
                        ...payments.map(
                          (p) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(p.paymentMode.name.toUpperCase(), style: baseText),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(currency.format(p.amount), style: baseText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }

            pw.Widget adjustmentsSection() {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  sectionTitle('Bill Adjustments'),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
                    columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(3)},
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Type', style: baseText),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Amount', style: baseText),
                          ),
                        ],
                      ),
                      ...adjustments.map(
                        (a) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Discount', style: baseText),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(currency.format(a.amount), style: baseText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            if (adjustments.isEmpty) {
              return [paymentsSection(), pw.SizedBox(height: 6)];
            } else {
              return [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: paymentsSection()),
                    pw.SizedBox(width: 8),
                    pw.Expanded(child: adjustmentsSection()),
                  ],
                ),
                pw.SizedBox(height: 6),
              ];
            }
          }()),

          // Summary
          sectionTitle('Bill Total'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
            columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(3)},
            children: [
              _summaryRowBold('Grand Total', bill.summary.grandTotal, currency),
              _summaryRowHighlighted('Pending Amount', bill.summary.pendingAmount, currency),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // _summaryRow kept earlier is removed as unused to satisfy lints

  static pw.TableRow _summaryRowBold(String label, double value, NumberFormat currency) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(currency.format(value), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _summaryRowHighlighted(String label, double value, NumberFormat currency) {
    return pw.TableRow(
      children: [
        pw.Container(
          color: PdfColors.red100,
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
          ),
        ),
        pw.Container(
          color: PdfColors.red100,
          padding: const pw.EdgeInsets.all(2),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              currency.format(value),
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
            ),
          ),
        ),
      ],
    );
  }

  // Removed local enum display helpers in favor of enum extension helpers
}
