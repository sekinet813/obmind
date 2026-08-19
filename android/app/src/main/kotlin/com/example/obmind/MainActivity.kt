package com.example.obmind

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingPickResult: MethodChannel.Result? = null
    private lateinit var documentTreeAccess: DocumentTreeAccess

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        documentTreeAccess = DocumentTreeAccess(contentResolver)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFolder" -> pickFolder(result)
                    "createMarkdown" -> createMarkdown(call.arguments, result)
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_OPEN_TREE) {
            return
        }
        val result = pendingPickResult
        pendingPickResult = null
        if (result == null) {
            return
        }
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
        } catch (_: SecurityException) {
            // Session grant from the picker may still allow create in this process.
        }
        result.success(uri.toString())
    }

    private fun pickFolder(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("already_picking", "Folder picker is already open", null)
            return
        }
        pendingPickResult = result
        val intent =
            Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
            }
        startActivityForResult(intent, REQUEST_OPEN_TREE)
    }

    private fun createMarkdown(
        arguments: Any?,
        result: MethodChannel.Result,
    ) {
        val args = arguments as? Map<*, *>
        val folderToken = args?.get("folderToken") as? String
        val displayName = args?.get("displayName") as? String
        val markdown = args?.get("markdown") as? String ?: ""
        if (folderToken.isNullOrEmpty() || displayName.isNullOrEmpty()) {
            result.error("invalid_args", "folderToken and displayName are required", null)
            return
        }

        Thread {
            try {
                val created =
                    documentTreeAccess.createMarkdown(folderToken, displayName, markdown)
                runOnUiThread {
                    result.success(
                        hashMapOf(
                            "uri" to created.first,
                            "displayName" to created.second,
                        ),
                    )
                }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error("create_failed", error.message, null)
                }
            }
        }.start()
    }

    private companion object {
        const val CHANNEL = "dev.obmind.storage"
        const val REQUEST_OPEN_TREE = 0x4f42
    }
}
