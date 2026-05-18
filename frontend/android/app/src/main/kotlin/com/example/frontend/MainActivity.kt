package com.example.frontend

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val mediaSaverChannel = "mochi/media_saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            mediaSaverChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")

                    if (bytes == null || bytes.isEmpty()) {
                        result.error("EMPTY_IMAGE", "Image bytes are empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = saveImageToGallery(
                            bytes = bytes,
                            fileName = fileName?.takeIf { it.isNotBlank() } ?: "mochi_image.jpg",
                            mimeType = mimeType?.takeIf { it.isNotBlank() } ?: "image/jpeg"
                        )
                        result.success(uri)
                    } catch (error: Exception) {
                        result.error("SAVE_IMAGE_FAILED", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(
        bytes: ByteArray,
        fileName: String,
        mimeType: String
    ): String {
        val resolver = applicationContext.contentResolver
        val imageCollection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }

        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/Mochi"
                )
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val imageUri = resolver.insert(imageCollection, values)
            ?: throw IllegalStateException("Cannot create image in MediaStore")

        resolver.openOutputStream(imageUri)?.use { outputStream ->
            outputStream.write(bytes)
        } ?: throw IllegalStateException("Cannot open image output stream")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(imageUri, values, null, null)
        }

        return imageUri.toString()
    }
}
