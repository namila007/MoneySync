package me.namila.money_sync

import java.io.File
import java.io.IOException

internal const val nativeSecurityChannelName = "me.namila.money_sync/security"

internal fun interface DatabasePathProvider {
    @Throws(IOException::class)
    fun databasePath(): String
}

internal class NoBackupDatabasePathProvider(
    private val noBackupFilesDirectory: File,
) : DatabasePathProvider {
    override fun databasePath(): String {
        val databaseDirectory = File(noBackupFilesDirectory, "money_sync/database")
        if (!databaseDirectory.exists() && !databaseDirectory.mkdirs()) {
            throw IOException("Unable to prepare secure storage.")
        }
        if (!databaseDirectory.isDirectory) {
            throw IOException("Secure storage is unavailable.")
        }

        return File(databaseDirectory, "money_sync.db").absolutePath
    }
}

internal interface SecureWindowController {
    fun setEnabled(enabled: Boolean)
}

internal class AndroidSecureWindowController(
    private val updateWindowFlags: (Boolean) -> Unit,
) : SecureWindowController {
    override fun setEnabled(enabled: Boolean) {
        updateWindowFlags(enabled)
    }
}

internal sealed interface NativeChannelResponse {
    data class Success(val value: Any?) : NativeChannelResponse

    data class Error(
        val code: String,
        val message: String,
    ) : NativeChannelResponse

    data object NotImplemented : NativeChannelResponse
}

internal class NativeSecurityChannelHandler(
    private val databasePathProvider: DatabasePathProvider,
    private val secureWindowController: SecureWindowController,
) {
    fun handle(method: String, arguments: Any?): NativeChannelResponse = when (method) {
        "getSensitiveDatabasePath" -> getSensitiveDatabasePath()
        "setSecureWindowProtection" -> setSecureWindowProtection(arguments)
        else -> NativeChannelResponse.NotImplemented
    }

    private fun getSensitiveDatabasePath(): NativeChannelResponse = try {
        NativeChannelResponse.Success(databasePathProvider.databasePath())
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "STORAGE_UNAVAILABLE",
            message = "Secure local storage is unavailable.",
        )
    }

    private fun setSecureWindowProtection(arguments: Any?): NativeChannelResponse {
        val enabled = arguments.singleBooleanArgument("enabled")
            ?: return NativeChannelResponse.Error(
                code = "INVALID_ARGUMENT",
                message = "A boolean enabled value is required.",
            )
        if (!enabled) {
            return NativeChannelResponse.Error(
                code = "INVALID_ARGUMENT",
                message = "Secure-window protection can only be enforced.",
            )
        }

        return try {
            secureWindowController.setEnabled(true)
            NativeChannelResponse.Success(null)
        } catch (_: Exception) {
            NativeChannelResponse.Error(
                code = "SECURE_WINDOW_UNAVAILABLE",
                message = "Secure-window protection is unavailable.",
            )
        }
    }
}

private fun Any?.singleBooleanArgument(name: String): Boolean? {
    val values = this as? Map<*, *> ?: return null
    if (values.keys != setOf(name)) return null
    return values[name] as? Boolean
}
