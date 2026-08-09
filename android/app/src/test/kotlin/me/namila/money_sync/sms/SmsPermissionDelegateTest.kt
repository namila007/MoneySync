package me.namila.money_sync.sms

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SmsPermissionDelegateTest {

    @Test
    fun `unavailable delegate never reaches requestPermissions`() {
        val delegate = UnavailableSmsPermissionDelegate()
        val status = delegate.currentStatus()
        assertEquals(TransportSmsPermissionStatus.UNAVAILABLE_IN_BUILD, status)

        var callbackInvoked = false
        delegate.requestReadSms { result ->
            callbackInvoked = true
            val status = result.getOrNull()
            assertEquals(TransportSmsPermissionStatus.UNAVAILABLE_IN_BUILD, status)
        }
        assertTrue(callbackInvoked)
    }

    @Test
    fun `unavailable delegate currentStatus is idempotent`() {
        val delegate = UnavailableSmsPermissionDelegate()
        assertEquals(delegate.currentStatus(), delegate.currentStatus())
    }
}
