package me.namila.money_sync.sms

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

private const val REQUEST_CODE_READ_SMS = 0x5341
private const val PREFS = "sms_permission_state"
private const val KEY_REQUESTED_ONCE = "requested_once"

class RuntimeSmsPermissionDelegate(private val activity: Activity) : SmsPermissionDelegate {

    private var pending: ((Result<TransportSmsPermissionStatus>) -> Unit)? = null

    private val prefs = activity.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private var hasRequestedOnce: Boolean
        get() = prefs.getBoolean(KEY_REQUESTED_ONCE, false)
        set(value) = prefs.edit().putBoolean(KEY_REQUESTED_ONCE, value).apply()

    override fun currentStatus(): TransportSmsPermissionStatus {
        val granted = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_SMS) ==
            PackageManager.PERMISSION_GRANTED
        if (granted) return TransportSmsPermissionStatus.GRANTED
        if (!hasRequestedOnce) return TransportSmsPermissionStatus.NOT_REQUESTED
        return if (ActivityCompat.shouldShowRequestPermissionRationale(
                activity, Manifest.permission.READ_SMS
            )
        ) TransportSmsPermissionStatus.DENIED
        else TransportSmsPermissionStatus.PERMANENTLY_DENIED
    }

    override fun requestReadSms(callback: (Result<TransportSmsPermissionStatus>) -> Unit) {
        if (pending != null) {
            callback(Result.failure(IllegalStateException("request_already_in_flight")))
            return
        }
        pending = callback
        hasRequestedOnce = true
        ActivityCompat.requestPermissions(
            activity, arrayOf(Manifest.permission.READ_SMS), REQUEST_CODE_READ_SMS
        )
    }

    override fun onResult(requestCode: Int) {
        if (requestCode != REQUEST_CODE_READ_SMS) return
        val cb = pending ?: return
        pending = null
        cb(Result.success(currentStatus()))
    }

    override fun openAppSettings() {
        activity.startActivity(
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.fromParts("package", activity.packageName, null)
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }
}
