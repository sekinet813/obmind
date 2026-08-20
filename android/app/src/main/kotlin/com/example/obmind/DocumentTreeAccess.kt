package com.example.obmind

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import java.io.IOException

internal class DocumentTreeAccess(
    private val contentResolver: ContentResolver,
) {
    fun hasFolderAccess(treeUriString: String): Boolean {
        return try {
            listMarkdown(treeUriString)
            true
        } catch (_: Exception) {
            false
        }
    }
    fun createMarkdown(
        treeUriString: String,
        displayName: String,
        markdown: String,
    ): Pair<String, String> {
        val parentUri = treeRootDocumentUri(treeUriString)
        val fileUri =
            DocumentsContract.createDocument(
                contentResolver,
                parentUri,
                // text/plain makes SAF append .txt even when the name already ends with .md.
                MARKDOWN_MIME,
                displayName,
            ) ?: throw IOException("createDocument returned null")
        writeFully(fileUri, markdown.toByteArray(Charsets.UTF_8))
        return fileUri.toString() to displayName
    }

    fun readMarkdown(fileUriString: String): String {
        return readFully(Uri.parse(fileUriString)).toString(Charsets.UTF_8)
    }

    fun writeMarkdown(fileUriString: String, markdown: String) {
        val fileUri = Uri.parse(fileUriString)
        val bytes = markdown.toByteArray(Charsets.UTF_8)
        val parentUri = parentDocumentUri(fileUri)
        val tempUri =
            DocumentsContract.createDocument(
                contentResolver,
                parentUri,
                MARKDOWN_MIME,
                TEMP_FILE_NAME,
            ) ?: throw IOException("cannot create temp markdown")
        var keepTemp = false
        try {
            writeFully(tempUri, bytes)
            try {
                writeFully(fileUri, bytes)
            } catch (writeError: Exception) {
                try {
                    writeFully(fileUri, readFully(tempUri))
                } catch (_: Exception) {
                    keepTemp = true
                }
                throw writeError
            }
        } finally {
            if (!keepTemp) {
                try {
                    DocumentsContract.deleteDocument(contentResolver, tempUri)
                } catch (_: Exception) {
                }
            }
        }
    }

    fun listMarkdown(treeUriString: String): List<Map<String, String>> {
        val treeUri = Uri.parse(treeUriString)
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                DocumentsContract.getTreeDocumentId(treeUri),
            )
        val results = mutableListOf<Map<String, String>>()
        val cursor =
            contentResolver.query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                ),
                null,
                null,
                null,
            ) ?: throw IOException("cannot query children")
        cursor.use {
            val idIndex = it.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameIndex =
                it.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val mimeIndex = it.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (it.moveToNext()) {
                val name = it.getString(nameIndex) ?: continue
                val mime = it.getString(mimeIndex).orEmpty()
                if (!isMarkdownFile(name, mime)) {
                    continue
                }
                val documentId = it.getString(idIndex)
                val uri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)
                results +=
                    mapOf(
                        "uri" to uri.toString(),
                        "displayName" to name,
                    )
            }
        }
        return results
    }

    fun renameMarkdown(
        fileUriString: String,
        newDisplayName: String,
    ): Pair<String, String> {
        val fileUri = Uri.parse(fileUriString)
        val documentId = DocumentsContract.getDocumentId(fileUri)
        val parentId =
            if (documentId.contains('/')) {
                documentId.substringBeforeLast('/')
            } else {
                DocumentsContract.getTreeDocumentId(fileUri)
            }
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(fileUri, parentId)
        val cursor =
            contentResolver.query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                ),
                null,
                null,
                null,
            ) ?: throw IOException("cannot query siblings")
        cursor.use {
            val nameIndex =
                it.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val idIndex = it.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            while (it.moveToNext()) {
                val name = it.getString(nameIndex) ?: continue
                val siblingId = it.getString(idIndex)
                if (name.equals(newDisplayName, ignoreCase = true) && siblingId != documentId) {
                    throw IOException("name already exists")
                }
            }
        }
        val renamed =
            DocumentsContract.renameDocument(
                contentResolver,
                fileUri,
                newDisplayName,
            ) ?: throw IOException("renameDocument returned null")
        return renamed.toString() to newDisplayName
    }

    fun deleteMarkdown(fileUriString: String) {
        val fileUri = Uri.parse(fileUriString)
        val deleted = DocumentsContract.deleteDocument(contentResolver, fileUri)
        if (!deleted) {
            throw IOException("deleteDocument returned false")
        }
    }

    private fun treeRootDocumentUri(treeUriString: String): Uri {
        val treeUri = Uri.parse(treeUriString)
        return DocumentsContract.buildDocumentUriUsingTree(
            treeUri,
            DocumentsContract.getTreeDocumentId(treeUri),
        )
    }

    private fun parentDocumentUri(fileUri: Uri): Uri {
        val documentId = DocumentsContract.getDocumentId(fileUri)
        val parentId =
            if (documentId.contains('/')) {
                documentId.substringBeforeLast('/')
            } else {
                DocumentsContract.getTreeDocumentId(fileUri)
            }
        return DocumentsContract.buildDocumentUriUsingTree(fileUri, parentId)
    }

    private fun isMarkdownFile(
        name: String,
        mime: String,
    ): Boolean {
        if (name == TEMP_FILE_NAME) {
            return false
        }
        val lower = name.lowercase()
        return lower.endsWith(".md") ||
            lower.endsWith(".markdown") ||
            mime == MARKDOWN_MIME ||
            mime == "text/x-markdown"
    }

    private fun readFully(uri: Uri): ByteArray {
        return contentResolver.openInputStream(uri)?.use { input ->
            input.readBytes()
        } ?: throw IOException("cannot open input stream")
    }

    private fun writeFully(
        uri: Uri,
        bytes: ByteArray,
    ) {
        contentResolver.openOutputStream(uri, "wt")?.use { output ->
            output.write(bytes)
            output.flush()
        } ?: throw IOException("cannot open output stream")
    }

    private companion object {
        const val MARKDOWN_MIME = "text/markdown"
        const val TEMP_FILE_NAME = ".obmind-tmp.md"
    }
}
