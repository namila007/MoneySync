package me.namila.money_sync.sms

import android.app.Activity
import android.database.Cursor
import android.provider.Telephony

class SmsHistoryHostApiImpl(private val activity: Activity) : SmsHistoryHostApi {
    companion object {
        private const val HARD_CAP = 500
        private const val MAX_BODY_LENGTH = 2000
    }

    override fun queryInbox(request: SmsHistoryRequest): SmsHistoryPageResult {
        val limit = request.limit.toInt().coerceIn(1, HARD_CAP)
        val offset = request.offset.toInt().coerceAtLeast(0)

        val selection = buildSelection(request)
        val selectionArgs = buildSelectionArgs(request)

        val messages = mutableListOf<SmsHistoryMessage?>()

        activity.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
            ),
            selection,
            selectionArgs,
            "date DESC LIMIT $limit OFFSET $offset"
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                if (messages.size >= limit) break
                messages.add(mapCursor(cursor))
            }
        }

        return SmsHistoryPageResult(messages = messages, hasMore = messages.size >= limit)
    }

    override fun countInbox(request: SmsHistoryRequest): Long {
        var count = 0L
        activity.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf("COUNT(*)"),
            buildSelection(request),
            buildSelectionArgs(request),
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                count = cursor.getLong(0)
            }
        }

        return count
    }

    override fun distinctSenders(): List<String?> {
        // ponytail: sorts by address and dedupes consecutive rows; O(rows) read
        val senders = mutableListOf<String?>()
        var last: String? = null
        activity.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms.ADDRESS),
            null,
            null,
            "address ASC"
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val address = cursor.getString(0) ?: continue
                if (address != last) {
                    senders.add(address)
                    last = address
                }
            }
        }
        return senders
    }

    private fun buildSelection(request: SmsHistoryRequest): String {
        val clauses = mutableListOf("date >= ?", "date <= ?")
        request.senderFilters?.filterNotNull()?.takeIf { it.isNotEmpty() }?.let { filters ->
            clauses.add("(" + filters.joinToString(" OR ") { "address = ?" } + ")")
        }
        return clauses.joinToString(" AND ")
    }

    private fun buildSelectionArgs(request: SmsHistoryRequest): Array<String> {
        val args = mutableListOf(
            request.fromEpochMs.toString(),
            request.untilEpochMs.toString(),
        )
        request.senderFilters?.filterNotNull()?.takeIf { it.isNotEmpty() }?.let {
            args.addAll(it)
        }
        return args.toTypedArray()
    }

    private fun mapCursor(cursor: Cursor): SmsHistoryMessage {
        val body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY))
            ?.take(MAX_BODY_LENGTH) ?: ""

        return SmsHistoryMessage(
            providerRowId = cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms._ID)),
            address = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)) ?: "",
            body = body,
            dateEpochMs = cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)),
        )
    }
}
