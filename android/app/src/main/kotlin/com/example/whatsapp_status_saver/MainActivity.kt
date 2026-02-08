
package com.example.whatsapp_status_saver

import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.statussaver/storage"
    private val REQUEST_CODE_OPEN_DIRECTORY = 1001
    
    private var methodResult: MethodChannel.Result? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openDirectoryPicker" -> {
                        methodResult = result
                        openDirectoryPicker()
                    }
                    "getStatusFiles" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString != null) {
                            val files = getFilesFromUri(Uri.parse(uriString))
                            result.success(files)
                        } else {
                            result.error("INVALID_URI", "URI is null", null)
                        }
                    }
                    "checkUriPermission" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString != null) {
                            val hasPermission = checkUriPermission(Uri.parse(uriString))
                            result.success(hasPermission)
                        } else {
                            result.success(false)
                        }
                    }
                    "getBytesFromUri" -> {
                        // NEW: Get image bytes from content URI
                        val uriString = call.argument<String>("uri")
                        if (uriString != null) {
                            val bytes = getBytesFromContentUri(Uri.parse(uriString))
                            result.success(bytes)
                        } else {
                            result.error("INVALID_URI", "URI is null", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun openDirectoryPicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        }
        startActivityForResult(intent, REQUEST_CODE_OPEN_DIRECTORY)
    }
    
    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_CODE_OPEN_DIRECTORY && resultCode == RESULT_OK) {
            data?.data?.let { uri ->
                val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                contentResolver.takePersistableUriPermission(uri, takeFlags)
                
                methodResult?.success(uri.toString())
                methodResult = null
            } ?: run {
                methodResult?.error("CANCELLED", "User cancelled", null)
                methodResult = null
            }
        } else if (requestCode == REQUEST_CODE_OPEN_DIRECTORY) {
            methodResult?.error("CANCELLED", "User cancelled", null)
            methodResult = null
        }
    }
    
    private fun getFilesFromUri(uri: Uri): List<Map<String, Any?>> {
        val files = mutableListOf<Map<String, Any?>>()
        
        try {
            val documentFile = DocumentFile.fromTreeUri(this, uri) ?: return files
            
            documentFile.listFiles().forEach { file ->
                if (file.name != ".nomedia") {
                    val mimeType = file.type ?: ""
                    val isVideo = mimeType.startsWith("video/") || 
                                  file.name?.endsWith(".mp4") == true ||
                                  file.name?.endsWith(".mkv") == true ||
                                  file.name?.endsWith(".avi") == true ||
                                  file.name?.endsWith(".3gp") == true
                    
                    val isImage = mimeType.startsWith("image/") ||
                                  file.name?.endsWith(".jpg") == true ||
                                  file.name?.endsWith(".jpeg") == true ||
                                  file.name?.endsWith(".png") == true ||
                                  file.name?.endsWith(".webp") == true
                    
                    if (isVideo || isImage) {
                        files.add(mapOf(
                            "uri" to file.uri.toString(),
                            "name" to file.name,
                            "isVideo" to isVideo,
                            "size" to file.length(),
                            "lastModified" to file.lastModified()
                        ))
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return files
    }
    
    private fun getBytesFromContentUri(uri: Uri): ByteArray? {
        return try {
            val inputStream = contentResolver.openInputStream(uri)
            val outputStream = ByteArrayOutputStream()
            
            inputStream?.use { input ->
                val buffer = ByteArray(4096)
                var bytesRead: Int
                while (input.read(buffer).also { bytesRead = it } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                }
            }
            
            outputStream.toByteArray()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    private fun checkUriPermission(uri: Uri): Boolean {
        return try {
            contentResolver.persistedUriPermissions.any { 
                it.uri == uri && it.isReadPermission 
            }
        } catch (e: Exception) {
            false
        }
    }
}