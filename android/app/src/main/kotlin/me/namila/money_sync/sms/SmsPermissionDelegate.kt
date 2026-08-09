package me.namila.money_sync.sms

interface SmsPermissionDelegate {
    fun currentStatus(): TransportSmsPermissionStatus
    fun requestReadSms(callback: (Result<TransportSmsPermissionStatus>) -> Unit)
    fun openAppSettings()
    fun onResult(requestCode: Int) {}
}

class UnavailableSmsPermissionDelegate : SmsPermissionDelegate {
    override fun currentStatus() = TransportSmsPermissionStatus.UNAVAILABLE_IN_BUILD

    override fun requestReadSms(callback: (Result<TransportSmsPermissionStatus>) -> Unit) {
        callback(Result.success(TransportSmsPermissionStatus.UNAVAILABLE_IN_BUILD))
    }

    override fun openAppSettings() = Unit
}
