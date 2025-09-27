import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'dart:io';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/route_constants.dart';

/// Barcode printing service using MethodChannel
class BarcodePrintService {
  static const _channel = MethodChannel('barcode_print');

  static Future<void> print(String barcode) async {
    AppLogger.success('Printing barcode: $barcode', 'BLUETOOTH_PRINT');
    await _channel.invokeMethod('testPrint', {'barcode': barcode});
    AppLogger.success('Barcode printed successfully', 'BLUETOOTH_PRINT');
  }
}

class BluetoothPrintPage extends StatefulWidget {
  final String barcodeData;

  const BluetoothPrintPage({super.key, required this.barcodeData});

  @override
  State<BluetoothPrintPage> createState() => _BluetoothPrintPageState();
}

class _BluetoothPrintPageState extends State<BluetoothPrintPage> {
  bool _isLoading = false;
  String _currentStep = 'Ready to print';
  String? _platformError;

  @override
  void initState() {
    super.initState();
    AppLogger.info('BluetoothPrintPage initialized', category: 'BLUETOOTH_PRINT');
    AppLogger.methodEntry('initState', className: 'BluetoothPrintPage');
    _checkPlatformSupport();
  }

  void _checkPlatformSupport() {
    AppLogger.methodEntry('_checkPlatformSupport', className: 'BluetoothPrintPage');
    if (kIsWeb) {
      _platformError = 'Bluetooth printing is not supported on web browsers. Please use a mobile device.';
      AppLogger.warning('Bluetooth printing not supported on web', category: 'BLUETOOTH_PRINT');
    } else if (Platform.isAndroid) {
      _platformError = null;
      AppLogger.info('Android platform detected', category: 'BLUETOOTH_PRINT');
    } else if (Platform.isIOS) {
      _platformError = 'This build supports printing only on Android.';
      AppLogger.info('iOS platform detected (not supported in this build)', category: 'BLUETOOTH_PRINT');
    } else {
      _platformError = 'Bluetooth printing is supported only on Android in this build.';
      AppLogger.warning('Unsupported platform for Bluetooth printing', category: 'BLUETOOTH_PRINT');
    }

    setState(() {
      _currentStep = _platformError == null ? 'Ready to print' : 'Platform not supported';
    });

    AppLogger.methodExit('_checkPlatformSupport', className: 'BluetoothPrintPage');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Building BluetoothPrintPage UI',
      category: 'BLUETOOTH_PRINT',
      data: {'isLoading': _isLoading, '_platformError': _platformError},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printing Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppLogger.navigation('BluetoothPrintPage', 'Previous Page');
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              AppLogger.navigation('BluetoothPrintPage', 'Dashboard');
              context.go(RouteConstants.dashboard);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bluetooth Printing Test', style: ResponsiveText.getTitle(context)),
                    const SizedBox(height: 8),
                    Text('Barcode: ${widget.barcodeData}', style: ResponsiveText.getBody(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Platform Support Warning
            if (_platformError != null)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text('Platform Notice', style: ResponsiveText.getSubtitle(context)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_platformError!, style: ResponsiveText.getBody(context)),
                    ],
                  ),
                ),
              ),
            if (_platformError != null) const SizedBox(height: 16),

            // Current Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Status', style: ResponsiveText.getSubtitle(context)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(_isLoading ? Icons.hourglass_empty : Icons.info, color: _isLoading ? Colors.orange : Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_currentStep, style: ResponsiveText.getBody(context))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Print via MethodChannel
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Print Barcode', style: ResponsiveText.getSubtitle(context)),
                    const SizedBox(height: 8),
                    Text('Send barcode to printer via MethodChannel.', style: ResponsiveText.getBody(context)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading || _platformError != null
                            ? null
                            : () async {
                                AppLogger.userInteraction(
                                  'Print Barcode via MethodChannel',
                                  screen: 'BluetoothPrintPage',
                                  details: {'barcodeData': widget.barcodeData},
                                );
                                try {
                                  setState(() {
                                    _isLoading = true;
                                    _currentStep = 'Printing barcode via MethodChannel...';
                                  });
                                  await BarcodePrintService.print(widget.barcodeData);
                                  setState(() {
                                    _isLoading = false;
                                    _currentStep = 'Barcode sent via MethodChannel. Check your printer.';
                                  });
                                  if (mounted) {
                                    SnackbarUtils.showSuccess(context, 'Barcode sent via MethodChannel successfully.');
                                  }
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                    _currentStep = 'MethodChannel print failed: $e';
                                  });
                                  if (mounted) {
                                    SnackbarUtils.showError(context, 'MethodChannel print failed: $e');
                                  }
                                }
                              },
                        icon: const Icon(Icons.print),
                        label: const Text('Print Barcode (MethodChannel)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
