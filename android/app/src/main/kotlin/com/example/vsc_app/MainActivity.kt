package com.example.vsc_app

import android.Manifest
import android.os.Bundle
import android.util.Log
import android.os.Build
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.dothantech.lpapi.LPAPI
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {

    private var lpapi: LPAPI? = null
    private var pendingBarcode: String? = null

    companion object {
        private const val REQUEST_BT_PERMISSIONS = 1001
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "barcode_print")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "testPrint" -> {
                        testPrint(call.argument<String>("barcode") ?: "")
                        result.success("Test initiated")
                    }
                    else -> result.notImplemented()
                }
            }

        // Initialize the API
        lpapi = LPAPI.Factory.createInstance()
    }

    private fun testPrint(barcode: String) {
        Log.d("LPAPI", "Starting print job...")
        if (!hasBluetoothPermissions()) {
            pendingBarcode = barcode
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_SCAN
                ),
                REQUEST_BT_PERMISSIONS
            )
            Log.d("LPAPI", "Requested Bluetooth runtime permissions")
            return
        }
    
        val opened = lpapi?.openPrinter(null as String?)
        Log.d("LPAPI", "Printer opened? $opened")
    
        lpapi?.startJob(40.0, 20.0, 0)
        Log.d("LPAPI", "Job started with size 40x20")
    
        val safeData = barcode.ifBlank { "1234567890" }
        val type = 28
    
        Log.d("LPAPI", "Printing barcode: $safeData, type: $type")
    
        lpapi?.draw1DBarcode(
            safeData,
            type,
            1.0,
            1.0,
            30.0,
            15.0,
            5.0
        )
    
        Log.d("LPAPI", "draw1DBarcode completed")
    
        lpapi?.commitJob()
        Log.d("LPAPI", "Job committed")
    }
    
    private fun hasBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BT_PERMISSIONS) {
            val allGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (allGranted) {
                pendingBarcode?.let { testPrint(it) }
            } else {
                Log.e("LPAPI", "Bluetooth permissions denied")
            }
            pendingBarcode = null
        }
    }

}
