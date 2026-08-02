package me.namila.money_sync

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.KeyProtection
import java.io.File
import java.io.IOException
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.Mac
import javax.crypto.SecretKey
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

    // The underlying platform KeyStore, shared so other components (e.g.
    // HmacSigner) do not open a second handle to the same store.
    val rawKeyStore: KeyStore get() = keyStore

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

    // Returns the raw content-key bytes. Ownership transfers to the caller,
    // which crosses the platform channel exactly once and must zeroize the
    // buffer immediately after keying the database — see
    // DatabaseKeyHandle.useAndDispose on the Dart side and
    // docs/adr/0001-native-database-key-boundary.md.
    fun acquireContentKeyBytes(): ByteArray {
        val wrapped = keyFileStore.loadWrappedKey()
        return wrappedKeyStore.unwrapContentKey(wrapped)
    }

    fun deleteAllKeys() {
        wrappedKeyStore.deleteWrapperKey()
        keyFileStore.deleteKeyFile()
    }
}

/**
 * Bounded, typed fields for source-identity HMAC canonicalization, mirroring
 * the length-prefixed canonical encoding already used by
 * SourceMessageCanonicalizer in Dart. Every field is re-validated here —
 * the Dart-side validation in SourceIdentityCanonicalizationRequest is
 * defense in depth, never a trust boundary.
 */
internal data class SourceIdentityCanonicalizationRequest(
    val senderAddress: String,
    val messageFamily: String,
    val maskedInstrumentEvidence: String,
    val occurredAtEpochSeconds: Long,
    val canonicalizationVersion: Int,
) {
    companion object {
        const val MAX_FIELD_LENGTH = 256

        fun fromChannelArguments(arguments: Map<*, *>): SourceIdentityCanonicalizationRequest {
            val sender = requireBoundedField(arguments["senderAddress"])
            val family = requireBoundedField(arguments["messageFamily"])
            val evidence = requireBoundedField(arguments["maskedInstrumentEvidence"])
            val occurredAt = (arguments["occurredAtEpochSeconds"] as? Number)?.toLong()
                ?: throw IllegalArgumentException("occurredAtEpochSeconds is required.")
            val version = (arguments["canonicalizationVersion"] as? Int)
                ?: throw IllegalArgumentException("canonicalizationVersion is required.")
            if (occurredAt < 0) {
                throw IllegalArgumentException("occurredAtEpochSeconds must not be negative.")
            }
            return SourceIdentityCanonicalizationRequest(sender, family, evidence, occurredAt, version)
        }

        private fun requireBoundedField(value: Any?): String {
            val text = value as? String
                ?: throw IllegalArgumentException("Canonicalization fields must be strings.")
            if (text.isEmpty() || text.length > MAX_FIELD_LENGTH) {
                throw IllegalArgumentException(
                    "Canonicalization fields must be 1-$MAX_FIELD_LENGTH characters."
                )
            }
            if (text.any { it.code < 0x20 || it.code == 0x7f }) {
                throw IllegalArgumentException(
                    "Canonicalization fields must not contain control characters."
                )
            }
            return text
        }
    }

    /**
     * Builds the canonical byte encoding natively — the caller never
     * supplies a pre-built string to sign.
     */
    fun toCanonicalBytes(): ByteArray {
        val builder = StringBuilder("v$canonicalizationVersion")
        for (field in listOf(senderAddress, messageFamily, maskedInstrumentEvidence)) {
            val fieldBytes = field.toByteArray(Charsets.UTF_8)
            builder.append('|').append(fieldBytes.size).append(':').append(field)
        }
        builder.append('|').append(occurredAtEpochSeconds)
        return builder.toString().toByteArray(Charsets.UTF_8)
    }
}

/**
 * Signs source-identity digests using a dedicated, non-exportable
 * AndroidKeyStore `KEY_ALGORITHM_HMAC_SHA256` key. The key material never
 * leaves the Keystore: `Mac` is initialized directly from the Keystore-held
 * `SecretKey`, not from an app-owned `ByteArray`/`SecretKeySpec`.
 */
internal class HmacSigner(
    private val wrappedKeyStore: WrappedKeyStore,
    private val noBackupFilesDirectory: File,
) {
    companion object {
        const val HMAC_KEY_ALIAS = "money_sync_source_identity_hmac_v2"
        const val HMAC_SUPPORTED_VERSION = 1
    }

    private val legacyHmacKeyFile: File
        get() = File(File(noBackupFilesDirectory, "money_sync/database"), "hmac_key_wrapped.blob")

    /**
     * Ensures a non-exportable Keystore HMAC key exists. If a legacy
     * AES-wrapped key file exists from before this migration, its raw key
     * material is imported once into the Keystore (preserving source-identity
     * continuity), zeroized, and the legacy file is deleted. Fresh installs
     * generate a new Keystore-native key directly.
     */
    fun ensureHmacKey() {
        val keyStore = wrappedKeyStore.rawKeyStore
        if (keyStore.containsAlias(HMAC_KEY_ALIAS)) return
        if (legacyHmacKeyFile.exists()) {
            migrateLegacyKey(keyStore)
        } else {
            generateFreshKey()
        }
    }

    private fun generateFreshKey() {
        val spec = KeyGenParameterSpec.Builder(HMAC_KEY_ALIAS, KeyProperties.PURPOSE_SIGN)
            .setDigests(KeyProperties.DIGEST_SHA256)
            .build()
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_HMAC_SHA256,
            WrappedKeyStore.ANDROID_KEYSTORE,
        )
        generator.init(spec)
        generator.generateKey()
    }

    private fun migrateLegacyKey(keyStore: KeyStore) {
        val wrapped = legacyHmacKeyFile.readBytes()
        val raw = wrappedKeyStore.unwrapContentKey(wrapped)
        try {
            val protection = KeyProtection.Builder(KeyProperties.PURPOSE_SIGN)
                .setDigests(KeyProperties.DIGEST_SHA256)
                .build()
            keyStore.setEntry(
                HMAC_KEY_ALIAS,
                KeyStore.SecretKeyEntry(SecretKeySpec(raw, "HmacSHA256")),
                protection,
            )
        } finally {
            raw.fill(0)
        }
        legacyHmacKeyFile.delete()
    }

    fun deleteHmacKey() {
        val keyStore = wrappedKeyStore.rawKeyStore
        if (keyStore.containsAlias(HMAC_KEY_ALIAS)) {
            keyStore.deleteEntry(HMAC_KEY_ALIAS)
        }
        if (legacyHmacKeyFile.exists()) {
            legacyHmacKeyFile.delete()
        }
    }

    fun deriveSourceIdentityDigest(request: SourceIdentityCanonicalizationRequest): String {
        require(request.canonicalizationVersion == HMAC_SUPPORTED_VERSION) {
            "Unsupported canonicalization version: ${request.canonicalizationVersion}"
        }
        ensureHmacKey()
        val key = wrappedKeyStore.rawKeyStore.getKey(HMAC_KEY_ALIAS, null) as SecretKey
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(key)
        val digest = mac.doFinal(request.toCanonicalBytes())
        return digest.joinToString("") { "%02x".format(it) }
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
        "acquireContentKeyBytes" -> acquireContentKeyBytes()
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

    private fun acquireContentKeyBytes(): NativeChannelResponse = try {
        NativeChannelResponse.Success(databaseKeyManager.acquireContentKeyBytes())
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
        val request = try {
            SourceIdentityCanonicalizationRequest.fromChannelArguments(args)
        } catch (_: IllegalArgumentException) {
            return NativeChannelResponse.Error(
                code = "INVALID_ARGUMENT",
                message = "Canonicalization request is invalid.",
            )
        }
        if (request.canonicalizationVersion != HmacSigner.HMAC_SUPPORTED_VERSION) {
            return NativeChannelResponse.Error(
                code = "UNSUPPORTED_VERSION",
                message = "Unsupported canonicalization version.",
            )
        }
        return try {
            NativeChannelResponse.Success(hmacSigner.deriveSourceIdentityDigest(request))
        } catch (_: Exception) {
            NativeChannelResponse.Error(
                code = "HMAC_FAILED",
                message = "Source identity digest failed.",
            )
        }
    }

    private fun deleteKeys(): NativeChannelResponse = try {
        databaseKeyManager.deleteAllKeys()
        hmacSigner.deleteHmacKey()
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
