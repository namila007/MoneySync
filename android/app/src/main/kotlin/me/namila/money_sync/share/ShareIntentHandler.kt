package me.namila.money_sync.share

import android.content.Intent

object ShareIntentHandler {
    private const val MAX_BODY_CHARS = 2000

    fun extractSharedText(intent: Intent): SharedTextPayload? {
        if (intent.action != Intent.ACTION_SEND) return null
        if (intent.type != "text/plain") return null

        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return null
        val truncated = if (text.length > MAX_BODY_CHARS) text.take(MAX_BODY_CHARS) else text

        return SharedTextPayload(
            text = truncated,
            mimeType = intent.type,
            sourcePackage = intent.`package`,
        )
    }
}
