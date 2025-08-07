package com.example.vsc_app

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.dothantech.lpapi.LPAPI

class MainActivity : FlutterActivity() {

    private var lpapi: LPAPI? = null

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
    
        val opened = lpapi?.openPrinter(null as String?)
        Log.d("LPAPI", "Printer opened? $opened")
    
        lpapi?.startJob(60.0, 40.0, 0)
        Log.d("LPAPI", "Job started with size 60x40")
    
        val safeData = barcode.ifBlank { "1234567890" }
        val type = 28
    
        Log.d("LPAPI", "Printing barcode: $safeData, type: $type")
    
        lpapi?.draw1DBarcode(
            safeData,
            type,
            10.0,
            10.0,
            40.0,
            20.0,
            2.0
        )
    
        Log.d("LPAPI", "draw1DBarcode completed")
    
        lpapi?.commitJob()
        Log.d("LPAPI", "Job committed")
    }
    
}
