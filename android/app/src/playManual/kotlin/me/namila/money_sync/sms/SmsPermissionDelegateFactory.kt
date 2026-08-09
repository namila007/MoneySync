package me.namila.money_sync.sms

import android.app.Activity

object SmsPermissionDelegateFactory {
    fun create(activity: Activity): SmsPermissionDelegate = UnavailableSmsPermissionDelegate()
}
