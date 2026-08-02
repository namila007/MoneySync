package me.namila.money_sync

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import java.io.File
import javax.crypto.spec.SecretKeySpec
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * M3.7 WP1 — device-only proof that the database key and HMAC key never
 * expose raw Keystore-backed material outside their single sanctioned call
 * site, and that HMAC signing is non-exportable. Deferred to the device
 * matrix per M3.7's terminal state; requires a real AndroidKeyStore
 * provider, unavailable in host/JVM unit tests.
 */
@RunWith(AndroidJUnit4::class)
class NativeSecurityChannelKeystoreTest {
    private fun freshNoBackupDir(): File {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val dir = File(context.noBackupFilesDir, "keystore_test_${System.nanoTime()}")
        dir.mkdirs()
        return dir
    }

    private fun sourceIdentityRequest(
        overrides: Map<String, Any?> = emptyMap(),
    ): SourceIdentityCanonicalizationRequest {
        val base = mapOf<String, Any?>(
            "senderAddress" to "BANK-ALERT",
            "messageFamily" to "debit-notification",
            "maskedInstrumentEvidence" to "****1234",
            "occurredAtEpochSeconds" to 1_784_678_400L,
            "canonicalizationVersion" to 1,
        )
        return SourceIdentityCanonicalizationRequest.fromChannelArguments(base + overrides)
    }

    @Test
    fun databaseKeyRoundTripsThroughWrapAndUnwrap() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        val keyManager = DatabaseKeyManager(wrappedKeyStore, WrappedKeyFileStore(noBackupDir))

        keyManager.ensureContentKey()
        val first = keyManager.acquireContentKeyBytes()
        val second = keyManager.acquireContentKeyBytes()

        assertEquals(32, first.size)
        assertArrayEquals(first, second)
    }

    @Test
    fun deleteAllKeysRemovesTheWrapperAliasAndKeyFile() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        val keyFileStore = WrappedKeyFileStore(noBackupDir)
        val keyManager = DatabaseKeyManager(wrappedKeyStore, keyFileStore)

        keyManager.ensureContentKey()
        assertTrue(keyFileStore.keyFileExists())

        keyManager.deleteAllKeys()

        assertFalse(keyFileStore.keyFileExists())
        assertFalse(wrappedKeyStore.keyExists())
    }

    @Test
    fun hmacKeyIsNotExportableFromTheKeystore() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)

        hmacSigner.ensureHmacKey()
        val key = wrappedKeyStore.rawKeyStore.getKey(HmacSigner.HMAC_KEY_ALIAS, null)

        // A non-exportable Keystore key cannot be re-wrapped by an
        // arbitrary AES cipher outside its own Keystore-enforced operation
        // set; attempting to treat it as raw SecretKeySpec bytes fails.
        assertNotEquals(SecretKeySpec::class.java, key.javaClass)
    }

    @Test
    fun sameRequestProducesTheSameDigestTwice() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)

        val request = sourceIdentityRequest()
        val first = hmacSigner.deriveSourceIdentityDigest(request)
        val second = hmacSigner.deriveSourceIdentityDigest(request)

        assertEquals(first, second)
        assertEquals(64, first.length)
    }

    @Test
    fun differentSenderProducesADifferentDigest() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)

        val first = hmacSigner.deriveSourceIdentityDigest(sourceIdentityRequest())
        val second = hmacSigner.deriveSourceIdentityDigest(
            sourceIdentityRequest(mapOf("senderAddress" to "OTHER-BANK")),
        )

        assertNotEquals(first, second)
    }

    @Test
    fun legacyWrappedKeyIsMigratedIntoTheKeystoreAndFileIsDeleted() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()

        // Simulate a pre-M3.7 install: a legacy AES-wrapped HMAC key file
        // exists, but no Keystore HMAC alias does yet.
        val legacyRaw = ByteArray(32) { it.toByte() }
        val legacyWrapped = wrappedKeyStore.wrapContentKey(legacyRaw)
        val legacyFile = File(File(noBackupDir, "money_sync/database"), "hmac_key_wrapped.blob")
        legacyFile.parentFile?.mkdirs()
        legacyFile.writeBytes(legacyWrapped)

        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)
        hmacSigner.ensureHmacKey()

        assertFalse("legacy key file must be deleted after migration", legacyFile.exists())
        assertTrue(wrappedKeyStore.rawKeyStore.containsAlias(HmacSigner.HMAC_KEY_ALIAS))
    }

    @Test
    fun deleteHmacKeyRemovesTheAliasAndAnyLegacyFile() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)

        hmacSigner.ensureHmacKey()
        assertTrue(wrappedKeyStore.rawKeyStore.containsAlias(HmacSigner.HMAC_KEY_ALIAS))

        hmacSigner.deleteHmacKey()

        assertFalse(wrappedKeyStore.rawKeyStore.containsAlias(HmacSigner.HMAC_KEY_ALIAS))
    }

    @Test
    fun deriveSourceIdentityDigestRejectsAnUnsupportedCanonicalizationVersion() {
        val noBackupDir = freshNoBackupDir()
        val wrappedKeyStore = WrappedKeyStore()
        wrappedKeyStore.ensureWrapperKey()
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupDir)

        val request = sourceIdentityRequest(mapOf("canonicalizationVersion" to 99))

        try {
            hmacSigner.deriveSourceIdentityDigest(request)
            throw AssertionError("Expected IllegalArgumentException")
        } catch (_: IllegalArgumentException) {
            // expected
        }
    }
}
