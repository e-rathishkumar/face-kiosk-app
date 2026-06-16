package com.siddhan.employeelogs.kiosk

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import java.io.File
import java.io.FileOutputStream
import java.nio.FloatBuffer
import kotlin.math.sqrt

/**
 * ONNX Runtime face recognition engine for edge AI inference.
 * Uses MobileFaceNet (1.2MB, 512-d embeddings) optimized for mobile.
 * 
 * Input: 112x112 RGB face crop
 * Output: 512-d L2-normalized embedding vector
 * 
 * Inference time: ~15-30ms on Helio G85 (CPU)
 */
class FaceRecognitionEngine(private val context: Context) {
    
    private var ortEnvironment: OrtEnvironment? = null
    private var ortSession: OrtSession? = null
    private val inputSize = 112 // MobileFaceNet input size
    private val embeddingSize = 512 // MobileFaceNet output dimension
    
    /**
     * Initialize ONNX model from assets or file path.
     * @param modelPath Optional external path; if null, loads from assets/models/
     */
    fun initModel(modelPath: String?) {
        ortEnvironment = OrtEnvironment.getEnvironment()
        
        val sessionOptions = OrtSession.SessionOptions().apply {
            // Optimize for mobile: use fewer threads, enable graph optimization
            setIntraOpNumThreads(2) // Helio G85 has 8 cores, use 2 for inference
            setOptimizationLevel(OrtSession.SessionOptions.OptLevel.ALL_OPT)
        }
        
        val resolvedPath = if (modelPath != null && File(modelPath).exists()) {
            modelPath
        } else {
            // Copy from assets to internal storage (ONNX requires file path)
            copyAssetToInternal("models/mobilefacenet.onnx")
        }
        
        ortSession = ortEnvironment!!.createSession(resolvedPath, sessionOptions)
    }
    
    /**
     * Generate 512-d face embedding from a cropped face image.
     * 
     * @param imageBytes Raw pixel bytes (RGBA or RGB format from camera)
     * @param width Image width
     * @param height Image height
     * @return FloatArray of 512 L2-normalized embedding values
     */
    fun generateEmbedding(imageBytes: ByteArray, width: Int, height: Int): FloatArray {
        val session = ortSession ?: throw IllegalStateException("Model not initialized")
        val env = ortEnvironment ?: throw IllegalStateException("Environment not initialized")
        
        // Decode bytes to bitmap
        val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            ?: throw IllegalArgumentException("Could not decode image bytes")
        
        // Resize to model input size (112x112)
        val resizedBitmap = Bitmap.createScaledBitmap(bitmap, inputSize, inputSize, true)
        bitmap.recycle()
        
        // Convert to float tensor [1, 3, 112, 112] (NCHW format, normalized)
        val inputTensor = bitmapToTensor(resizedBitmap)
        resizedBitmap.recycle()
        
        // Run inference
        val onnxTensor = OnnxTensor.createTensor(env, inputTensor, longArrayOf(1, 3, inputSize.toLong(), inputSize.toLong()))
        val results = session.run(mapOf(session.inputNames.first() to onnxTensor))
        
        // Extract embedding
        val outputTensor = results[0].value as Array<FloatArray>
        val embedding = outputTensor[0]
        
        // L2 normalize
        val normalized = l2Normalize(embedding)
        
        onnxTensor.close()
        results.close()
        
        return normalized
    }
    
    /**
     * Get device temperature for thermal monitoring.
     */
    fun getDeviceTemperature(): Double {
        return try {
            val file = File("/sys/class/thermal/thermal_zone0/temp")
            if (file.exists()) {
                val temp = file.readText().trim().toDouble()
                temp / 1000.0 // Convert from millidegrees
            } else {
                -1.0 // Temperature not available
            }
        } catch (e: Exception) {
            -1.0
        }
    }
    
    fun dispose() {
        ortSession?.close()
        ortEnvironment?.close()
        ortSession = null
        ortEnvironment = null
    }
    
    /**
     * Convert bitmap to NCHW float tensor with normalization.
     * Standard face recognition preprocessing:
     * - Scale pixel values to [-1, 1] range
     */
    private fun bitmapToTensor(bitmap: Bitmap): FloatBuffer {
        val pixels = IntArray(inputSize * inputSize)
        bitmap.getPixels(pixels, 0, inputSize, 0, 0, inputSize, inputSize)
        
        val buffer = FloatBuffer.allocate(1 * 3 * inputSize * inputSize)
        
        // NCHW format: batch, channel, height, width
        for (c in 0 until 3) { // RGB channels
            for (y in 0 until inputSize) {
                for (x in 0 until inputSize) {
                    val pixel = pixels[y * inputSize + x]
                    val value = when (c) {
                        0 -> ((pixel shr 16) and 0xFF).toFloat() // R
                        1 -> ((pixel shr 8) and 0xFF).toFloat()  // G
                        2 -> (pixel and 0xFF).toFloat()           // B
                        else -> 0f
                    }
                    // Normalize to [-1, 1]
                    buffer.put((value - 127.5f) / 127.5f)
                }
            }
        }
        buffer.rewind()
        return buffer
    }
    
    /**
     * L2 normalize embedding vector.
     */
    private fun l2Normalize(vector: FloatArray): FloatArray {
        var sum = 0.0f
        for (v in vector) sum += v * v
        val norm = sqrt(sum.toDouble()).toFloat()
        if (norm < 1e-10f) return vector
        return FloatArray(vector.size) { vector[it] / norm }
    }
    
    /**
     * Copy an asset file to internal storage for ONNX Runtime.
     */
    private fun copyAssetToInternal(assetName: String): String {
        val outFile = File(context.filesDir, assetName)
        if (outFile.exists()) return outFile.absolutePath
        
        outFile.parentFile?.mkdirs()
        context.assets.open(assetName).use { input ->
            FileOutputStream(outFile).use { output ->
                input.copyTo(output)
            }
        }
        return outFile.absolutePath
    }
}
