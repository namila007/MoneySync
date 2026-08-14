package me.namila.money_sync.sms

import android.app.Activity

object SmsPermissionDelegateFactory {
    fun create(activity: Activity): SmsPermissionDelegate =
        UnavailableSmsPermissionDelegate()
}

object SmsHistoryDelegateFactory {
    fun create(activity: Activity): SmsHistoryHostApi =
        object : SmsHistoryHostApi {
            override fun queryInbox(request: SmsHistoryRequest): SmsHistoryPageResult =
                SmsHistoryPageResult(messages = emptyList(), hasMore = false)

            override fun countInbox(request: SmsHistoryRequest): Long = 0

            override fun distinctSenders(): List<String?> = emptyList()
        }
}
