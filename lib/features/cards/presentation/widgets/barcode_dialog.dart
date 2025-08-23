import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/features/cards/presentation/providers/card_detail_provider.dart';

/// A dialog widget for barcode entry and scanning
class BarcodeDialog extends StatefulWidget {
  const BarcodeDialog({super.key});

  /// Shows the barcode dialog and returns the entered barcode
  static Future<void> show(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (context) => ChangeNotifierProvider(create: (_) => CardDetailProvider(), child: const BarcodeDialog()),
    );
  }

  @override
  State<BarcodeDialog> createState() => _BarcodeDialogState();
}

class _BarcodeDialogState extends State<BarcodeDialog> {
  // Variables for barcode scanning
  String? _lastScannedBarcode;
  DateTime? _lastScanTime;
  final TextEditingController _barcodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Barcode'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barcode',
                hintText: 'Enter barcode',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _openBarcodeScanner(context),
                  tooltip: 'Scan Barcode',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => _searchCard(context),
          // style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryColor, foregroundColor: Colors.white),
          child: const Text('Search Card'),
        ),
      ],
    );
  }

  /// Opens the barcode scanner camera
  Future<void> _openBarcodeScanner(BuildContext context) async {
    try {
      final String? scannedBarcode = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Scan Barcode'),
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
            ),
            body: MobileScanner(
              controller: MobileScannerController(detectionSpeed: DetectionSpeed.normal, facing: CameraFacing.back, torchEnabled: false),
              onDetect: (capture) {
                try {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String barcode = barcodes.first.rawValue ?? '';
                    if (barcode.isNotEmpty) {
                      final now = DateTime.now();
                      if (_lastScannedBarcode == barcode && _lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 2) {
                        return;
                      }

                      _lastScannedBarcode = barcode;
                      _lastScanTime = now;
                      Navigator.of(context).pop(barcode);
                    }
                  }
                } catch (e) {
                  try {
                    Navigator.of(context).pop();
                    SnackbarUtils.showError(context, 'Error processing barcode: $e');
                  } catch (_) {}
                }
              },
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Camera Error', style: ResponsiveText.getTitle(context)),
                      const SizedBox(height: 8),
                      Text(error.errorDetails?.message ?? 'Unknown error occurred'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go Back')),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
        _barcodeController.text = scannedBarcode;
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Could not open camera. Please enter barcode manually.');
    }
  }

  /// Searches for a card by barcode and navigates to its detail page
  Future<void> _searchCard(BuildContext context) async {
    if (_barcodeController.text.isNotEmpty) {
      final barcode = _barcodeController.text.trim();
      final cardDetailProvider = Provider.of<CardDetailProvider>(context, listen: false);

      try {
        await cardDetailProvider.getCardByBarcode(barcode);
        final cardId = cardDetailProvider.currentCard?.id;
        if (cardId != null) {
          context.pushNamed(RouteConstants.cardDetailRouteName, pathParameters: {'id': cardId}, extra: cardDetailProvider);
        } else {
          SnackbarUtils.showError(context, 'Card not found');
        }
      } catch (e) {
        SnackbarUtils.showError(context, 'Error searching for card: $e');
      }
    } else {
      SnackbarUtils.showWarning(context, 'Please enter a barcode');
    }
  }
}
