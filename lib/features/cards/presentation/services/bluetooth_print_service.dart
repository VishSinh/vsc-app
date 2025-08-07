import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue_thermal;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
// import 'package:barcode/barcode.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

/// A comprehensive Bluetooth printing service with multiple plugin options
class BluetoothPrintService {
  // Blue Thermal Printer
  static blue_thermal.BlueThermalPrinter bluetooth = blue_thermal.BlueThermalPrinter.instance;

  // Print Bluetooth Thermal
  // static PrintBluetoothThermal printBluetoothThermal = PrintBluetoothThermal();

  // Flutter Bluetooth Printer
  // static FlutterBluetoothPrinter flutterBluetoothPrinter = FlutterBluetoothPrinter();

  /// Show Bluetooth printing options dialog
  static Future<void> showPrintOptionsDialog(BuildContext context, String barcodeData) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Printing Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a Bluetooth printing plugin to test:'),
            const SizedBox(height: 16),
            _buildPrintButton(context, 'Blue Thermal Printer', Icons.print, () => _testBlueThermalPrinter(context, barcodeData)),
            // const SizedBox(height: 8),
            // _buildPrintButton(context, 'Print Bluetooth Thermal', Icons.print_outlined, () => _testPrintBluetoothThermal(context, barcodeData)),
            // const SizedBox(height: 8),
            // _buildPrintButton(context, 'Flutter Blue Plus', Icons.bluetooth, () => _testFlutterBluePlus(context, barcodeData)),
            // const SizedBox(height: 8),
            // _buildPrintButton(context, 'Flutter Bluetooth Printer', Icons.print_disabled, () => _testFlutterBluetoothPrinter(context, barcodeData)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
      ),
    );
  }

  static Widget _buildPrintButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
      ),
    );
  }

  /// Test Blue Thermal Printer plugin
  static Future<void> _testBlueThermalPrinter(BuildContext context, String barcodeData) async {
    try {
      // Check if Bluetooth is enabled
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == null || !isConnected) {
        // Scan for devices
        List<blue_thermal.BluetoothDevice> devices = await bluetooth.getBondedDevices();
        if (devices.isEmpty) {
          if (context.mounted) {
            SnackbarUtils.showError(context, 'No Bluetooth devices found');
          }
          return;
        }

        // Connect to first available device
        await bluetooth.connect(devices.first);
      }

      // For now, just print the barcode data as text
      // This will help us test the connection first
      await bluetooth.write('Barcode: $barcodeData\n\n');

      if (context.mounted) {
        SnackbarUtils.showSuccess(context, 'Printed using Blue Thermal Printer');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Blue Thermal Printer error: $e');
      }
    }
  }

  // /// Test Print Bluetooth Thermal plugin
  // static Future<void> _testPrintBluetoothThermal(BuildContext context, String barcodeData) async {
  //   try {
  //     // Get paired devices
  //     List<BluetoothInfo> devices = await PrintBluetoothThermal.pairedBluetooths;
  //     if (devices.isEmpty) {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'No paired Bluetooth devices found');
  //       }
  //       return;
  //     }

  //     // Connect to first device
  //     String? result = await PrintBluetoothThermal.connect(macPrinterAddress: devices.first.macAdress);
  //     if (result != 'true') {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'Failed to connect: $result');
  //       }
  //       return;
  //     }

  //     // Generate barcode
  //     final barcode = Barcode.code128();
  //     final barcodeBytes = barcode.make(barcodeData, width: 2, height: 70);

  //     // Print barcode
  //     await PrintBluetoothThermal.writeBytes(bytes: Uint8List.fromList(barcodeBytes));

  //     if (context.mounted) {
  //       SnackbarUtils.showSuccess(context, 'Printed using Print Bluetooth Thermal');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       SnackbarUtils.showError(context, 'Print Bluetooth Thermal error: $e');
  //     }
  //   }
  // }

  // /// Test Flutter Blue Plus plugin
  // static Future<void> _testFlutterBluePlus(BuildContext context, String barcodeData) async {
  //   try {
  //     // Check if Bluetooth is on
  //     if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'Please turn on Bluetooth');
  //       }
  //       return;
  //     }

  //     // Scan for devices
  //     await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  //     List<ScanResult> results = await FlutterBluePlus.scanResults.first;

  //     if (results.isEmpty) {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'No Bluetooth devices found');
  //       }
  //       return;
  //     }

  //     // Connect to first device
  //     BluetoothDevice device = results.first.device;
  //     await device.connect();

  //     // Find printer service
  //     List<BluetoothService> services = await device.discoverServices();
  //     BluetoothCharacteristic? printerCharacteristic;

  //     for (BluetoothService service in services) {
  //       for (BluetoothCharacteristic characteristic in service.characteristics) {
  //         if (characteristic.properties.write) {
  //           printerCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //       if (printerCharacteristic != null) break;
  //     }

  //     if (printerCharacteristic == null) {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'No printer service found');
  //       }
  //       return;
  //     }

  //     // Generate barcode
  //     final barcode = Barcode.code128();
  //     final barcodeBytes = barcode.make(barcodeData, width: 2, height: 70);

  //     // Print barcode
  //     await printerCharacteristic.write(Uint8List.fromList(barcodeBytes));

  //     if (context.mounted) {
  //       SnackbarUtils.showSuccess(context, 'Printed using Flutter Blue Plus');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       SnackbarUtils.showError(context, 'Flutter Blue Plus error: $e');
  //     }
  //   }
  // }

  // /// Test Flutter Bluetooth Printer plugin
  // static Future<void> _testFlutterBluetoothPrinter(BuildContext context, String barcodeData) async {
  //   try {
  //     // Get paired devices
  //     List<BluetoothDevice> devices = await flutterBluetoothPrinter.getBluetooths;
  //     if (devices.isEmpty) {
  //       if (context.mounted) {
  //         SnackbarUtils.showError(context, 'No paired Bluetooth devices found');
  //       }
  //       return;
  //     }

  //     // Connect to first device
  //     await flutterBluetoothPrinter.connect(devices.first);

  //     // Generate barcode
  //     final barcode = Barcode.code128();
  //     final barcodeBytes = barcode.make(barcodeData, width: 2, height: 70);

  //     // Print barcode
  //     await flutterBluetoothPrinter.writeBytes(Uint8List.fromList(barcodeBytes));

  //     if (context.mounted) {
  //       SnackbarUtils.showSuccess(context, 'Printed using Flutter Bluetooth Printer');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       SnackbarUtils.showError(context, 'Flutter Bluetooth Printer error: $e');
  //     }
  //   }
  // }
}
