package me.namila.money_sync.sms

import android.Manifest
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import androidx.test.core.app.ApplicationProvider
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SmsPermissionManifestTest {

    @Test
    fun mergedManifestDeclaresReadSmsWhenPresent() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        val info = context.packageManager.getPermissionInfo(
            Manifest.permission.READ_SMS, 0
        )

        assertNotNull("READ_SMS should be declared", info)
    }

    @Test
    fun mergedManifestDeclaresNoReceiveSendOrWriteSms() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val packageInfo = context.packageManager.getPackageInfo(
            context.packageName,
            PackageManager.GET_PERMISSIONS
        )

        val requestedPermissions = packageInfo.requestedPermissions?.toSet() ?: emptySet()

        assertTrue(
            "RECEIVE_SMS must not be declared",
            !requestedPermissions.contains(Manifest.permission.RECEIVE_SMS)
        )
        assertTrue(
            "SEND_SMS must not be declared",
            !requestedPermissions.contains(Manifest.permission.SEND_SMS)
        )
        assertTrue(
            "WRITE_SMS must not be declared",
            !requestedPermissions.contains("android.permission.WRITE_SMS")
        )
    }
}
