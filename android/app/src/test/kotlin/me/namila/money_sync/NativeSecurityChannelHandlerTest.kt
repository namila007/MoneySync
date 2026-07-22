package me.namila.money_sync

import java.io.IOException
import java.nio.file.Paths
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

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
        val handler = NativeSecurityChannelHandler(
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
        val handler = NativeSecurityChannelHandler(
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
        val handler = NativeSecurityChannelHandler(
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
        val handler = NativeSecurityChannelHandler(
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
        val handler = NativeSecurityChannelHandler(
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
        val handler = NativeSecurityChannelHandler(
            databasePathProvider = DatabasePathProvider { "unused" },
            secureWindowController = RecordingSecureWindowController(),
        )

        assertEquals(NativeChannelResponse.NotImplemented, handler.handle("unknown", null))
    }
}

private class RecordingSecureWindowController : SecureWindowController {
    val states = mutableListOf<Boolean>()

    override fun setEnabled(enabled: Boolean) {
        states += enabled
    }
}
