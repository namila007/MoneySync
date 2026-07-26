package me.namila.money_sync

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.io.File
import java.io.IOException
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

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

internal class WrappedKeyStore(
    private val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) },
) {
    companion object {
        const val ANDROID_KEYSTORE = "AndroidKeyStore"
        const val WRAP_KEY_ALIAS = "money_sync_key_wrap"
        const val CONTENT_KEY_SIZE_BITS = 256
        const val GCM_TAG_LENGTH_BITS = 128
        const val GCM_IV_LENGTH_BYTES = 12
    }

    private val wrapperKeyAlias: String = WRAP_KEY_ALIAS

    fun ensureWrapperKey() {
        if (keyStore.containsAlias(wrapperKeyAlias)) return
        val spec = KeyGenParameterSpec.Builder(
            wrapperKeyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(CONTENT_KEY_SIZE_BITS)
            .build()
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        generator.init(spec)
        generator.generateKey()
    }

    fun generateAndWrapContentKey(): ByteArray {
        val contentKey = ByteArray(CONTENT_KEY_SIZE_BITS / 8).also {
            SecureRandom().nextBytes(it)
        }
        val wrapped = wrapContentKey(contentKey)
        contentKey.fill(0)
        return wrapped
    }

    fun wrapContentKey(contentKey: ByteArray): ByteArray {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        val wrappingKey = (keyStore.getEntry(wrapperKeyAlias, null) as KeyStore.SecretKeyEntry).secretKey
        cipher.init(Cipher.ENCRYPT_MODE, wrappingKey)
        val ciphertext = cipher.doFinal(contentKey)
        val iv = cipher.iv
        return iv + ciphertext
    }

    fun unwrapContentKey(wrappedBlob: ByteArray): ByteArray {
        val iv = wrappedBlob.copyOfRange(0, GCM_IV_LENGTH_BYTES)
        val ciphertext = wrappedBlob.copyOfRange(GCM_IV_LENGTH_BYTES, wrappedBlob.size)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        val wrappingKey = (keyStore.getEntry(wrapperKeyAlias, null) as KeyStore.SecretKeyEntry).secretKey
        cipher.init(Cipher.DECRYPT_MODE, wrappingKey, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
        return cipher.doFinal(ciphertext)
    }

    fun keyExists(): Boolean = keyStore.containsAlias(wrapperKeyAlias)

    fun deleteWrapperKey() {
        if (keyStore.containsAlias(wrapperKeyAlias)) {
            keyStore.deleteEntry(wrapperKeyAlias)
        }
    }
}

internal class WrappedKeyFileStore(private val noBackupFilesDirectory: File) {
    private val keyFile: File
        get() = File(File(noBackupFilesDirectory, "money_sync/database"), "db_key_wrapped.blob")

    fun storeWrappedKey(wrapped: ByteArray) {
        val dir = keyFile.parentFile
        if (!dir.exists() && !dir.mkdirs()) {
            throw IOException("Cannot create key storage directory")
        }
        keyFile.writeBytes(wrapped)
    }

    fun loadWrappedKey(): ByteArray = keyFile.readBytes()

    fun keyFileExists(): Boolean = keyFile.exists()

    fun deleteKeyFile() {
        if (keyFile.exists()) keyFile.delete()
    }
}

internal class DatabaseKeyManager(
    private val wrappedKeyStore: WrappedKeyStore,
    private val keyFileStore: WrappedKeyFileStore,
) {
    fun ensureContentKey(): String {
        if (!wrappedKeyStore.keyExists()) {
            wrappedKeyStore.ensureWrapperKey()
        }
        if (!keyFileStore.keyFileExists()) {
            val wrapped = wrappedKeyStore.generateAndWrapContentKey()
            keyFileStore.storeWrappedKey(wrapped)
        }
        return "present"
    }

    fun acquireContentKeyHex(): String {
        val wrapped = keyFileStore.loadWrappedKey()
        val raw = wrappedKeyStore.unwrapContentKey(wrapped)
        try {
            val hex = raw.joinToString("") { "%02x".format(it) }
            return hex
        } finally {
            raw.fill(0)
        }
    }

    fun deleteAllKeys() {
        wrappedKeyStore.deleteWrapperKey()
        keyFileStore.deleteKeyFile()
    }
}

internal class HmacSigner(
    private val wrappedKeyStore: WrappedKeyStore,
    private val noBackupFilesDirectory: File,
) {
    companion object {
        const val HMAC_KEY_PURPOSE = "money_sync_source_identity_hmac"
        const val HMAC_SUPPORTED_VERSION = 1
    }

    private val hmacKeyFile: File
        get() = File(File(noBackupFilesDirectory, "money_sync/database"), "hmac_key_wrapped.blob")

    fun ensureHmacPurposeKey(): String {
        val blobFile = hmacKeyFile
        if (!blobFile.exists()) {
            val wrapped = wrappedKeyStore.generateAndWrapContentKey()
            blobFile.writeBytes(wrapped)
        }
        return "present"
    }

    fun deriveSourceIdentityDigest(
        canonicalInput: String,
        canonicalizationVersion: Int,
    ): String {
        if (canonicalizationVersion != HMAC_SUPPORTED_VERSION) {
            throw IllegalArgumentException(
                "Unsupported canonicalization version: $canonicalizationVersion"
            )
        }
        val hmacKey = acquireHmacKey()
        try {
            val mac = javax.crypto.Mac.getInstance("HmacSHA256")
            mac.init(SecretKeySpec(hmacKey, "HmacSHA256"))
            val domainPrefixed =
                "$HMAC_KEY_PURPOSE.v$canonicalizationVersion:$canonicalInput"
            val digest = mac.doFinal(domainPrefixed.toByteArray(Charsets.UTF_8))
            return digest.joinToString("") { "%02x".format(it) }
        } finally {
            hmacKey.fill(0)
        }
    }

    private fun acquireHmacKey(): ByteArray {
        val blobFile = hmacKeyFile
        if (!blobFile.exists()) throw IOException("HMAC key not initialized")
        val wrapped = blobFile.readBytes()
        return wrappedKeyStore.unwrapContentKey(wrapped)
    }
}

internal sealed interface NativeChannelResponse {
    data class Success(val value: Any?) : NativeChannelResponse
    data class Error(val code: String, val message: String) : NativeChannelResponse
    data object NotImplemented : NativeChannelResponse
}

internal class WalletTokenManager(
    private val wrappedKeyStore: WrappedKeyStore,
    private val noBackupFilesDirectory: File,
) {
    private val tokenFile: File
        get() = File(File(noBackupFilesDirectory, "money_sync/database"), "wallet_token.blob")

    fun storeToken(tokenHex: String) {
        val dir = tokenFile.parentFile
        if (!dir.exists() && !dir.mkdirs()) {
            throw IOException("Cannot create token storage directory")
        }
        val raw = tokenHex.hexToBytes()
        try {
            val wrapped = wrappedKeyStore.wrapContentKey(raw)
            tokenFile.writeBytes(wrapped)
        } finally {
            raw.fill(0)
        }
    }

    fun loadToken(): String {
        if (!tokenFile.exists()) throw IOException("Token not stored")
        val wrapped = tokenFile.readBytes()
        val raw = wrappedKeyStore.unwrapContentKey(wrapped)
        try {
            return raw.toHexString()
        } finally {
            raw.fill(0)
        }
    }

    fun deleteToken() {
        if (tokenFile.exists()) tokenFile.delete()
    }
}

internal class NativeSecurityChannelHandler(
    private val databasePathProvider: DatabasePathProvider,
    private val secureWindowController: SecureWindowController,
    private val databaseKeyManager: DatabaseKeyManager,
    private val hmacSigner: HmacSigner,
    private val noBackupFilesDirectory: File,
    private val wrappedKeyStore: WrappedKeyStore,
) {
    private val walletTokenManager = WalletTokenManager(wrappedKeyStore, noBackupFilesDirectory)
    fun handle(method: String, arguments: Any?): NativeChannelResponse = when (method) {
        "getSensitiveDatabasePath" -> getSensitiveDatabasePath()
        "ensureContentKey" -> ensureContentKey()
        "acquireContentKeyHex" -> acquireContentKeyHex()
        "deriveSourceIdentityDigest" -> deriveSourceIdentityDigest(arguments)
        "deleteKeys" -> deleteKeys()
        "storeWalletToken" -> storeWalletToken(arguments)
        "loadWalletToken" -> loadWalletToken()
        "deleteWalletToken" -> deleteWalletToken()
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

    private fun ensureContentKey(): NativeChannelResponse = try {
        NativeChannelResponse.Success(databaseKeyManager.ensureContentKey())
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "KEY_UNAVAILABLE",
            message = "Database key generation failed.",
        )
    }

    private fun acquireContentKeyHex(): NativeChannelResponse = try {
        NativeChannelResponse.Success(databaseKeyManager.acquireContentKeyHex())
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "KEY_UNAVAILABLE",
            message = "Database key is not available.",
        )
    }

    private fun deriveSourceIdentityDigest(arguments: Any?): NativeChannelResponse {
        val args = arguments as? Map<*, *> ?: return NativeChannelResponse.Error(
            code = "INVALID_ARGUMENT",
            message = "Arguments required.",
        )
        val input = args["canonicalInput"] as? String ?: return NativeChannelResponse.Error(
            code = "INVALID_ARGUMENT",
            message = "canonicalInput string required.",
        )
        val version = args["canonicalizationVersion"] as? Int ?: return NativeChannelResponse.Error(
            code = "INVALID_ARGUMENT",
            message = "canonicalizationVersion int required.",
        )
        return try {
            hmacSigner.ensureHmacPurposeKey()
            val digest = hmacSigner.deriveSourceIdentityDigest(input, version)
            NativeChannelResponse.Success(digest)
        } catch (_: IllegalArgumentException) {
            NativeChannelResponse.Error(
                code = "UNSUPPORTED_VERSION",
                message = "Unsupported canonicalization version.",
            )
        } catch (_: Exception) {
            NativeChannelResponse.Error(
                code = "HMAC_FAILED",
                message = "Source identity digest failed.",
            )
        }
    }

    private fun deleteKeys(): NativeChannelResponse = try {
        databaseKeyManager.deleteAllKeys()
        NativeChannelResponse.Success(null)
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "KEY_DELETION_FAILED",
            message = "Key deletion failed.",
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

    private fun storeWalletToken(arguments: Any?): NativeChannelResponse {
        val tokenHex = arguments as? String ?: return NativeChannelResponse.Error(
            code = "INVALID_ARGUMENT",
            message = "Token hex string required.",
        )
        return try {
            walletTokenManager.storeToken(tokenHex)
            NativeChannelResponse.Success(null)
        } catch (_: Exception) {
            NativeChannelResponse.Error(
                code = "TOKEN_STORAGE_FAILED",
                message = "Failed to store wallet token.",
            )
        }
    }

    private fun loadWalletToken(): NativeChannelResponse = try {
        NativeChannelResponse.Success(walletTokenManager.loadToken())
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "TOKEN_UNAVAILABLE",
            message = "Wallet token is not available.",
        )
    }

    private fun deleteWalletToken(): NativeChannelResponse = try {
        walletTokenManager.deleteToken()
        NativeChannelResponse.Success(null)
    } catch (_: Exception) {
        NativeChannelResponse.Error(
            code = "TOKEN_DELETION_FAILED",
            message = "Failed to delete wallet token.",
        )
    }
}

private fun Any?.singleBooleanArgument(name: String): Boolean? {
    val values = this as? Map<*, *> ?: return null
    if (values.keys != setOf(name)) return null
    return values[name] as? Boolean
}


private fun ByteArray.toHexString(): String = joinToString("") { "%02x".format(it) }

private fun String.hexToBytes(): ByteArray {
    val len = length / 2
    return ByteArray(len) { Integer.parseInt(substring(it * 2, it * 2 + 2), 16).toByte() }
}

private fun ByteArray.joinToString(
    separator: String = ", ",
    transform: ((Byte) -> CharSequence)? = null,
): String {
    val joiner = java.util.StringJoiner(separator)
    for (byte in this) {
        joiner.add(transform?.invoke(byte)?.toString() ?: byte.toString())
    }
    return joiner.toString()
}
