package me.namila.money_sync

import java.io.File
import java.io.IOException
import java.nio.file.Paths
import java.security.KeyStore
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

/**
 * A JVM-available (non-Android) KeyStore type stands in for
 * "AndroidKeyStore" here. None of the tests in this file exercise a method
 * that actually performs a Keystore-backed cryptographic operation — they
 * only cover databasePathProvider/secureWindowController dispatch — so the
 * fake never needs to behave like a real hardware-backed store.
 */
private fun fakeWrappedKeyStore(): WrappedKeyStore =
    WrappedKeyStore(KeyStore.getInstance("PKCS12").apply { load(null, null) })

private fun testHandler(
    databasePathProvider: DatabasePathProvider,
    secureWindowController: SecureWindowController,
    noBackupFilesDirectory: File = Paths.get("/tmp/no-backup-test").toFile(),
): NativeSecurityChannelHandler {
    val wrappedKeyStore = fakeWrappedKeyStore()
    return NativeSecurityChannelHandler(
        databasePathProvider = databasePathProvider,
        secureWindowController = secureWindowController,
        databaseKeyManager = DatabaseKeyManager(
            wrappedKeyStore,
            WrappedKeyFileStore(noBackupFilesDirectory),
        ),
        hmacSigner = HmacSigner(wrappedKeyStore, noBackupFilesDirectory),
        noBackupFilesDirectory = noBackupFilesDirectory,
        wrappedKeyStore = wrappedKeyStore,
    )
}

class NativeSecurityChannelHandlerTest {
    @Test
    fun `database path is inside no-backup directory`() {
        val path = NoBackupDatabasePathProvider(Paths.get("/tmp/no-backup").toFile()).databasePath()

        assertEquals(
            "/tmp/no-backup/money_sync/database/money_sync.db",
            path,
        )
    }

    @Test
    fun `database path request returns only the secure path`() {
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { "/tmp/no-backup/money_sync/database/money_sync.db" },
            secureWindowController = RecordingSecureWindowController(),
        )

        val response = handler.handle(method = "getSensitiveDatabasePath", arguments = null)

        assertTrue(response is NativeChannelResponse.Success)
        assertEquals(
            "/tmp/no-backup/money_sync/database/money_sync.db",
            (response as NativeChannelResponse.Success).value,
        )
    }

    @Test
    fun `database path failure is fail-closed and does not expose the exception`() {
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { throw IOException("/private/financial-data") },
            secureWindowController = RecordingSecureWindowController(),
        )

        val response = handler.handle(method = "getSensitiveDatabasePath", arguments = null)

        assertEquals(
            NativeChannelResponse.Error(
                code = "STORAGE_UNAVAILABLE",
                message = "Secure local storage is unavailable.",
            ),
            response,
        )
    }

    @Test
    fun `secure-window control requires one boolean enabled argument`() {
        val controller = RecordingSecureWindowController()
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { "unused" },
            secureWindowController = controller,
        )

        val response = handler.handle(
            method = "setSecureWindowProtection",
            arguments = mapOf("enabled" to "true"),
        )

        assertEquals(
            NativeChannelResponse.Error(
                code = "INVALID_ARGUMENT",
                message = "A boolean enabled value is required.",
            ),
            response,
        )
        assertTrue(controller.states.isEmpty())
    }

    @Test
    fun `secure-window control rejects attempts to clear protection`() {
        val controller = RecordingSecureWindowController()
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { "unused" },
            secureWindowController = controller,
        )

        val response = handler.handle(
            method = "setSecureWindowProtection",
            arguments = mapOf("enabled" to false),
        )

        assertEquals(
            NativeChannelResponse.Error(
                code = "INVALID_ARGUMENT",
                message = "Secure-window protection can only be enforced.",
            ),
            response,
        )
        assertTrue(controller.states.isEmpty())
    }

    @Test
    fun `secure-window control enforces protection`() {
        val controller = RecordingSecureWindowController()
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { "unused" },
            secureWindowController = controller,
        )

        val response = handler.handle(
            method = "setSecureWindowProtection",
            arguments = mapOf("enabled" to true),
        )

        assertEquals(NativeChannelResponse.Success(null), response)
        assertEquals(listOf(true), controller.states)
    }

    @Test
    fun `unknown methods remain unavailable`() {
        val handler = testHandler(
            databasePathProvider = DatabasePathProvider { "unused" },
            secureWindowController = RecordingSecureWindowController(),
        )

        assertEquals(NativeChannelResponse.NotImplemented, handler.handle("unknown", null))
    }
}

class SourceIdentityCanonicalizationRequestTest {
    private fun validArguments(overrides: Map<String, Any?> = emptyMap()): Map<String, Any?> {
        val base = mapOf<String, Any?>(
            "senderAddress" to "BANK-ALERT",
            "messageFamily" to "debit-notification",
            "maskedInstrumentEvidence" to "****1234",
            "occurredAtEpochSeconds" to 1_784_678_400L,
            "canonicalizationVersion" to 1,
        )
        return base + overrides
    }

    @Test
    fun `parses a fully valid channel argument map`() {
        val request = SourceIdentityCanonicalizationRequest.fromChannelArguments(validArguments())

        assertEquals("BANK-ALERT", request.senderAddress)
        assertEquals("debit-notification", request.messageFamily)
        assertEquals("****1234", request.maskedInstrumentEvidence)
        assertEquals(1_784_678_400L, request.occurredAtEpochSeconds)
        assertEquals(1, request.canonicalizationVersion)
    }

    @Test
    fun `rejects a missing sender address`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("senderAddress" to null)),
            )
        }
    }

    @Test
    fun `rejects an empty field`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("messageFamily" to "")),
            )
        }
    }

    @Test
    fun `rejects an oversized field`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("senderAddress" to "x".repeat(257))),
            )
        }
    }

    @Test
    fun `accepts a field at exactly the maximum length`() {
        val request = SourceIdentityCanonicalizationRequest.fromChannelArguments(
            validArguments(mapOf("senderAddress" to "x".repeat(256))),
        )
        assertEquals(256, request.senderAddress.length)
    }

    @Test
    fun `rejects a field containing control characters`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("maskedInstrumentEvidence" to "evi\ndence")),
            )
        }
    }

    @Test
    fun `rejects a non-string field`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("senderAddress" to 42)),
            )
        }
    }

    @Test
    fun `rejects a missing occurredAtEpochSeconds`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("occurredAtEpochSeconds" to null)),
            )
        }
    }

    @Test
    fun `rejects a negative occurredAtEpochSeconds`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("occurredAtEpochSeconds" to -1L)),
            )
        }
    }

    @Test
    fun `rejects a missing canonicalizationVersion`() {
        assertThrowsIllegalArgument {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(
                validArguments(mapOf("canonicalizationVersion" to null)),
            )
        }
    }

    @Test
    fun `canonical bytes differ when any single field differs`() {
        val base = SourceIdentityCanonicalizationRequest.fromChannelArguments(validArguments())
        val differentSender = SourceIdentityCanonicalizationRequest.fromChannelArguments(
            validArguments(mapOf("senderAddress" to "OTHER-BANK")),
        )
        val differentTimestamp = SourceIdentityCanonicalizationRequest.fromChannelArguments(
            validArguments(mapOf("occurredAtEpochSeconds" to 1_784_678_401L)),
        )

        assertNotEquals(
            String(base.toCanonicalBytes()),
            String(differentSender.toCanonicalBytes()),
        )
        assertNotEquals(
            String(base.toCanonicalBytes()),
            String(differentTimestamp.toCanonicalBytes()),
        )
    }

    @Test
    fun `canonical bytes are deterministic for identical fields`() {
        val first = SourceIdentityCanonicalizationRequest.fromChannelArguments(validArguments())
        val second = SourceIdentityCanonicalizationRequest.fromChannelArguments(validArguments())

        assertEquals(String(first.toCanonicalBytes()), String(second.toCanonicalBytes()))
    }

    @Test
    fun `length-prefixed encoding is not ambiguous across a field boundary shift`() {
        // "ab|c" split as sender="ab", family="c" must canonicalize
        // differently from sender="a", family="b|c" — the length prefix
        // prevents the classic delimiter-collision ambiguity.
        val first = SourceIdentityCanonicalizationRequest.fromChannelArguments(
            validArguments(mapOf("senderAddress" to "ab", "messageFamily" to "c")),
        )
        val second = SourceIdentityCanonicalizationRequest.fromChannelArguments(
            validArguments(mapOf("senderAddress" to "a", "messageFamily" to "b|c")),
        )

        assertNotEquals(String(first.toCanonicalBytes()), String(second.toCanonicalBytes()))
    }

    private fun assertThrowsIllegalArgument(block: () -> Unit) {
        try {
            block()
            fail("Expected IllegalArgumentException")
        } catch (_: IllegalArgumentException) {
            // expected
        }
    }
}

private class RecordingSecureWindowController : SecureWindowController {
    val states = mutableListOf<Boolean>()

    override fun setEnabled(enabled: Boolean) {
        states += enabled
    }
}
