package com.example.obmind

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import java.io.IOException

internal class DocumentTreeAccess(
    private val contentResolver: ContentResolver,
) {
    fun createMarkdown(
        treeUriString: String,
        displayName: String,
        markdown: String,
    ): Pair<String, String> {
        val treeUri = Uri.parse(treeUriString)
        val parentUri =
            DocumentsContract.buildDocumentUriUsingTree(
                treeUri,
                DocumentsContract.getTreeDocumentId(treeUri),
            )
        val fileUri =
            DocumentsContract.createDocument(
                contentResolver,
                parentUri,
                // text/plain makes SAF append .txt even when the name already ends with .md.
                "text/markdown",
                displayName,
            ) ?: throw IOException("createDocument returned null")

        contentResolver.openOutputStream(fileUri, "w").use { output ->
            if (output == null) {
                throw IOException("cannot open output stream")
            }
            output.write(markdown.toByteArray(Charsets.UTF_8))
            output.flush()
        }

        return fileUri.toString() to displayName
    }
}
