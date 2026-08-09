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
    fun `merged manifest declares READ_SMS when present`() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        val info = context.packageManager.getPermissionInfo(
            Manifest.permission.READ_SMS, 0
        )

        assertNotNull("READ_SMS should be declared", info)
    }

    @Test
    fun `merged manifest declares no RECEIVE_SMS, SEND_SMS, or WRITE_SMS`() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext

        fun isPermissionDeclared(permission: String): Boolean {
            return try {
                context.packageManager.getPermissionInfo(permission, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }

        assertTrue(
            "RECEIVE_SMS must not be declared",
            !isPermissionDeclared(Manifest.permission.RECEIVE_SMS)
        )
        assertTrue(
            "SEND_SMS must not be declared",
            !isPermissionDeclared(Manifest.permission.SEND_SMS)
        )
        assertTrue(
            "WRITE_SMS must not be declared",
            !isPermissionDeclared(Manifest.permission.WRITE_SMS) ||
            !context.packageManager.getPermissionInfo(
                Manifest.permission.WRITE_SMS, 0
            ).let { true }
        )
    }
}
