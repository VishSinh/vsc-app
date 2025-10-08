import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPrintPage extends StatefulWidget {
  final String barcodeData;

  const BluetoothPrintPage({super.key, required this.barcodeData});

  @override
  State<BluetoothPrintPage> createState() => _BluetoothPrintPageState();
}

class _BluetoothPrintPageState extends State<BluetoothPrintPage> {
  String _currentStep = 'Ready to print';
  String? _platformError;

  // LPAPI plugin state
  final LpapiThermalPrinter _lpapi = LpapiThermalPrinter();
  List<PrinterInfo> _printers = [];
  PrinterInfo? _selectedPrinter;
  String _lpStatus = 'disconnected';
  bool _pluginBusy = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('BluetoothPrintPage initialized', category: 'BLUETOOTH_PRINT');
    AppLogger.methodEntry('initState', className: 'BluetoothPrintPage');
    _checkPlatformSupport();
    // Auto-check printer connection status on page open
    Future(() async {
      await _refreshStatus();
      if (!mounted) return;
      setState(() {
        _currentStep = _lpStatus == 'connected' ? 'Printer already connected' : 'Ready to connect';
      });
    });
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

  Future<void> _requestBtPermissions() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Requesting Bluetooth permissions...';
    });
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    final granted = statuses.values.every((s) => s.isGranted);
    setState(() {
      _pluginBusy = false;
      _currentStep = granted ? 'Permissions granted' : 'Bluetooth permissions not fully granted';
    });
  }

  Future<void> _refreshStatus() async {
    try {
      final s = await _lpapi.getPrinterStatus();
      setState(() {
        _lpStatus = s;
      });
    } catch (_) {}
  }

  Future<bool> _waitUntilConnected({Duration timeout = const Duration(seconds: 5)}) async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < timeout) {
      try {
        final s = await _lpapi.getPrinterStatus();
        if (s == 'connected') {
          setState(() {
            _lpStatus = s;
          });
          return true;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  Future<void> _discoverPrinters() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Discovering printers...';
    });
    try {
      final found = await _lpapi.discoverPrinters();
      setState(() {
        _printers = found;
        if (_printers.isNotEmpty) {
          _selectedPrinter ??= _printers.first;
        }
        _currentStep = 'Found ${found.length} printers';
      });
      await _refreshStatus();
      if (_lpStatus == 'connected') {
        setState(() {
          _currentStep = 'Printer already connected';
        });
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Discovery failed: $e';
      });
      if (mounted) {
        SnackbarUtils.showError(context, 'Discovery failed: $e');
      }
    } finally {
      setState(() {
        _pluginBusy = false;
      });
    }
  }

  Future<void> _connectSelected() async {
    if (!Platform.isAndroid || _selectedPrinter == null) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Connecting to ${_selectedPrinter!.name}...';
    });
    try {
      await _refreshStatus();
      if (_lpStatus == 'connected') {
        setState(() {
          _currentStep = 'Already connected to a printer';
        });
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Already connected');
        }
        return;
      }
      final ok = await _lpapi.connectPrinter(_selectedPrinter!.address);
      bool becameConnected = ok && await _waitUntilConnected();
      await _refreshStatus();
      setState(() {
        _currentStep = becameConnected ? 'Connected to ${_selectedPrinter!.name}' : (ok ? 'Connecting...' : 'Connection failed');
      });
      if (mounted) {
        becameConnected
            ? SnackbarUtils.showSuccess(context, 'Connected to ${_selectedPrinter!.name}')
            : SnackbarUtils.showError(context, 'Connection failed');
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Connection error: $e';
      });
      if (mounted) {
        SnackbarUtils.showError(context, 'Connection error: $e');
      }
    } finally {
      setState(() {
        _pluginBusy = false;
      });
    }
  }

  Future<void> _quickConnect() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Quick connecting to first available printer...';
    });
    try {
      await _refreshStatus();
      if (_lpStatus == 'connected') {
        setState(() {
          _currentStep = 'Already connected to a printer';
        });
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Already connected');
        }
        return;
      }
      final ok = await _lpapi.connectFirstPrinter();
      bool becameConnected = ok && await _waitUntilConnected();
      await _refreshStatus();
      setState(() {
        _currentStep = becameConnected ? 'Connected to first available printer' : 'Quick connect failed';
      });
      if (mounted) {
        becameConnected
            ? SnackbarUtils.showSuccess(context, 'Connected to first available printer')
            : SnackbarUtils.showError(context, 'Quick connect failed');
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Quick connect error: $e';
      });
      if (mounted) {
        SnackbarUtils.showError(context, 'Quick connect error: $e');
      }
    } finally {
      setState(() {
        _pluginBusy = false;
      });
    }
  }

  Future<void> _printQrViaPlugin() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Printing QR via LPAPI plugin...';
    });
    try {
      // Optional: tune width/height based on your labels
      final ok = await _lpapi.print2DBarcode(widget.barcodeData, width: 28, height: 28);
      setState(() {
        _currentStep = ok ? 'QR sent to printer' : 'Print failed';
      });
      if (mounted) {
        ok ? SnackbarUtils.showSuccess(context, 'QR print sent successfully') : SnackbarUtils.showError(context, 'QR print failed');
      }
    } catch (e) {
      setState(() {
        _currentStep = 'QR print error: $e';
      });
      if (mounted) {
        SnackbarUtils.showError(context, 'QR print error: $e');
      }
    } finally {
      setState(() {
        _pluginBusy = false;
      });
    }
  }

  Future<void> _print1DViaPlugin() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _pluginBusy = true;
      _currentStep = 'Printing 1D Barcode via LPAPI plugin...';
    });
    try {
      final ok = await _lpapi.print1DBarcode(widget.barcodeData, text: '', width: 48, height: 30);
      setState(() {
        _currentStep = ok ? '1D barcode sent to printer' : 'Print failed';
      });
      if (mounted) {
        ok
            ? SnackbarUtils.showSuccess(context, '1D barcode print sent successfully')
            : SnackbarUtils.showError(context, '1D barcode print failed');
      }
    } catch (e) {
      setState(() {
        _currentStep = '1D barcode print error: $e';
      });
      if (mounted) {
        SnackbarUtils.showError(context, '1D barcode print error: $e');
      }
    } finally {
      setState(() {
        _pluginBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Building BluetoothPrintPage UI',
      category: 'BLUETOOTH_PRINT',
      data: {'pluginBusy': _pluginBusy, '_platformError': _platformError},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printing'),
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
            // Header + Current Status in the same row (responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                final headerCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bluetooth Printing', style: ResponsiveText.getTitle(context)),
                        const SizedBox(height: 8),
                        Text('Barcode: ${widget.barcodeData}', style: ResponsiveText.getBody(context)),
                      ],
                    ),
                  ),
                );

                final statusCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Status', style: ResponsiveText.getSubtitle(context)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(_pluginBusy ? Icons.hourglass_empty : Icons.info, color: _pluginBusy ? Colors.orange : Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_currentStep, style: ResponsiveText.getBody(context))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: headerCard),
                      const SizedBox(width: 16),
                      Expanded(child: statusCard),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [headerCard, const SizedBox(height: 16), statusCard],
                );
              },
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

            const SizedBox(height: 16),
            // LPAPI Plugin-based QR printing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LPAPI Plugin (QR Printing)', style: ResponsiveText.getSubtitle(context)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.bluetooth, color: _lpStatus == 'connected' ? Colors.green : Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Plugin status: $_lpStatus', style: ResponsiveText.getBody(context))),
                        IconButton(onPressed: _refreshStatus, icon: const Icon(Icons.refresh), tooltip: 'Refresh status'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: (_platformError != null) ? null : _requestBtPermissions,
                          icon: const Icon(Icons.security),
                          label: const Text('Request Permissions'),
                        ),
                        ElevatedButton.icon(
                          onPressed: (_platformError != null) ? null : _discoverPrinters,
                          icon: const Icon(Icons.search),
                          label: const Text('Discover Printers'),
                        ),
                        ElevatedButton.icon(
                          onPressed: (_platformError != null) ? null : _quickConnect,
                          icon: const Icon(Icons.link),
                          label: const Text('Quick Connect'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_printers.isNotEmpty && _lpStatus != 'connected') ...[
                      Text('Select Printer', style: ResponsiveText.getBody(context)),
                      const SizedBox(height: 8),
                      DropdownButton<PrinterInfo>(
                        isExpanded: true,
                        value: _selectedPrinter,
                        items: _printers.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (${p.address})'))).toList(),
                        onChanged: _pluginBusy
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedPrinter = val;
                                });
                              },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_platformError != null || _selectedPrinter == null) ? null : _connectSelected,
                          icon: const Icon(Icons.bluetooth_connected),
                          label: const Text('Connect to Selected'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_platformError != null) ? null : _printQrViaPlugin,
                            icon: const Icon(Icons.qr_code_2),
                            label: const Text('Print QR (LPAPI Plugin)'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_platformError != null) ? null : _print1DViaPlugin,
                            icon: const Icon(Icons.code),
                            label: const Text('Print 1D Barcode (LPAPI Plugin)'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
