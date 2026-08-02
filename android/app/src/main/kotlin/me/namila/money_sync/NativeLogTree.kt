package me.namila.money_sync

import android.util.Log
import timber.log.Timber

/**
 * A [Timber.Tree] that forwards native Android logs to the Dart-side
 * [NativeLogFlutterApi] via the Pigeon-generated bridge.
 *
 * Priority mapping per M3.6:
 *   VERBOSE (2) → priority 2
 *   DEBUG (3)   → priority 3
 *   INFO (4)    → priority 4
 *   WARN (5)    → priority 5
 *   ERROR (6)   → priority 6
 *   ASSERT (7)  → priority 7
 *
 * Only planted in release builds; DebugTree is for debug builds only.
 */
internal class NativeLogTree(
    private val flutterApi: NativeLogFlutterApi,
) : Timber.Tree() {

    override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
        val safeTag = tag ?: "unknown"
        val safeMessage = message.trim()

        if (safeMessage.isEmpty()) return

        flutterApi.onNativeLog(
            priority.toLong(),
            safeTag,
            safeMessage,
            null,
        ) {}
    }

    override fun isLoggable(tag: String?, priority: Int): Boolean {
        return priority >= Log.VERBOSE && priority <= Log.ASSERT
    }
}
