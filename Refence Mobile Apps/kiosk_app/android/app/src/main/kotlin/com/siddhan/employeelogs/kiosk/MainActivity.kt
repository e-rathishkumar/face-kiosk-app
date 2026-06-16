package com.siddhan.employeelogs.kiosk

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.siddhan.kiosk/face_engine"
    private var faceEngine: FaceRecognitionEngine? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        faceEngine = FaceRecognitionEngine(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initModel" -> {
                    try {
                        val modelPath = call.argument<String>("modelPath")
                        faceEngine!!.initModel(modelPath)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
                "generateEmbedding" -> {
                    try {
                        val imageBytes = call.argument<ByteArray>("imageBytes")!!
                        val width = call.argument<Int>("width")!!
                        val height = call.argument<Int>("height")!!
                        val embedding = faceEngine!!.generateEmbedding(imageBytes, width, height)
                        result.success(embedding.toList())
                    } catch (e: Exception) {
                        result.error("EMBEDDING_ERROR", e.message, null)
                    }
                }
                "getTemperature" -> {
                    val temp = faceEngine!!.getDeviceTemperature()
                    result.success(temp)
                }
                "dispose" -> {
                    faceEngine?.dispose()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep screen on for kiosk mode
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onDestroy() {
        faceEngine?.dispose()
        super.onDestroy()
    }
}
