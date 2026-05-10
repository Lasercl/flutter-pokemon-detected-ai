package com.example.flutter_pokemon_application

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.channels.FileChannel
import io.flutter.FlutterInjector

class MainActivity: FlutterActivity() {
    private val CHANNEL = "pokemon.inference"
    private var tflite: Interpreter? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "runInference") {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath != null) {
                    try {
                        val res = inferImage(imagePath)
                        result.success(res)
                    } catch (e: Exception) {
                        result.error("INFERENCE_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Image path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun inferImage(imagePath: String): Map<String, Any> {
        if (tflite == null) {
            val assetLookupKey = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset("assets/model_flutter.tflite")
            val fd = context.assets.openFd(assetLookupKey)
            val inputStream = FileInputStream(fd.fileDescriptor)
            val fileChannel = inputStream.channel
            val startOffset = fd.startOffset
            val declaredLength = fd.declaredLength
            val mappedByteBuffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)

            val options = Interpreter.Options()
            tflite = Interpreter(mappedByteBuffer, options)
        }

        val bitmap = BitmapFactory.decodeFile(imagePath) ?: throw Exception("Failed to decode image at $imagePath")
        
        val inputTensor = tflite!!.getInputTensor(0)
        val shape = inputTensor.shape() 
        val h = shape[1]
        val w = shape[2]
        val isInputQuantized = inputTensor.dataType() == org.tensorflow.lite.DataType.UINT8
        
        val scaledBitmap = android.graphics.Bitmap.createScaledBitmap(bitmap, w, h, true)
        val intValues = IntArray(w * h)
        scaledBitmap.getPixels(intValues, 0, w, 0, 0, w, h)
        
        val input = if (isInputQuantized) {
            val arr = Array(1) { Array(h) { Array(w) { ByteArray(3) } } }
            var pixel = 0
            for (i in 0 until h) {
                for (j in 0 until w) {
                    val pixelValue = intValues[pixel++]
                    arr[0][i][j][0] = ((pixelValue shr 16) and 0xFF).toByte()
                    arr[0][i][j][1] = ((pixelValue shr 8) and 0xFF).toByte()
                    arr[0][i][j][2] = (pixelValue and 0xFF).toByte()
                }
            }
            arr
        } else {
            val arr = Array(1) { Array(h) { Array(w) { FloatArray(3) } } }
            var pixel = 0
            for (i in 0 until h) {
                for (j in 0 until w) {
                    val pixelValue = intValues[pixel++]
                    arr[0][i][j][0] = ((pixelValue shr 16) and 0xFF) / 255.0f
                    arr[0][i][j][1] = ((pixelValue shr 8) and 0xFF) / 255.0f
                    arr[0][i][j][2] = (pixelValue and 0xFF) / 255.0f
                }
            }
            arr
        }
        
        val outputTensor = tflite!!.getOutputTensor(0)
        val outputShape = outputTensor.shape()
        val numClasses = outputShape[1]
        val isOutputQuantized = outputTensor.dataType() == org.tensorflow.lite.DataType.UINT8
        
        val output = if (isOutputQuantized) {
            Array(1) { ByteArray(numClasses) }
        } else {
            Array(1) { FloatArray(numClasses) }
        }
        
        tflite!!.run(input, output)
        
        val results = mutableListOf<Map<String, Any>>()
        for (i in 0 until numClasses) {
            val prob = if (isOutputQuantized) {
                ((output as Array<ByteArray>)[0][i].toInt() and 0xFF) / 255.0f
            } else {
                (output as Array<FloatArray>)[0][i]
            }
            results.add(mapOf("index" to i, "confidence" to prob))
        }
        
        val sortedResults = results.sortedByDescending { it["confidence"] as Float }.take(2)
        
        return mapOf("results" to sortedResults)
    }
}
