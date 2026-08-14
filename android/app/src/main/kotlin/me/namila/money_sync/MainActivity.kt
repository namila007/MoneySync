package me.namila.money_sync

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber
import me.namila.money_sync.sms.SmsPermissionDelegate
import me.namila.money_sync.sms.SmsPermissionDelegateFactory
import me.namila.money_sync.sms.SmsPermissionHostApi
import me.namila.money_sync.sms.SmsHistoryDelegateFactory
import me.namila.money_sync.sms.SmsHistoryHostApi
import me.namila.money_sync.sms.TransportSmsPermissionStatus
import me.namila.money_sync.share.ShareIntentHandler
import me.namila.money_sync.share.ShareIntentFlutterApi

class MainActivity : FlutterFragmentActivity() {
    private lateinit var securityChannelHandler: NativeSecurityChannelHandler
    private lateinit var wrappedKeyStore: WrappedKeyStore
    private lateinit var databaseKeyManager: DatabaseKeyManager
    private lateinit var nativeLogTree: NativeLogTree
    private var smsPermissionDelegate: SmsPermissionDelegate? = null
    private var shareIntentApi: ShareIntentFlutterApi? = null

    /** True for debuggable builds only; release builds always report false. */
    private fun isDebuggableBuild(): Boolean =
        (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Secure window is ON by default; the user can disable it via
        // Settings → Configuration → Screenshot protection (persisted),
        // which calls setSecureWindowProtection at runtime.
        setSecureWindowFlag(true)
        handleShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent) {
        val api = shareIntentApi ?: return
        val payload = ShareIntentHandler.extractSharedText(intent) ?: return
        api.onSharedText(payload) {}
    }

    private fun setSecureWindowFlag(enabled: Boolean) {
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        smsPermissionDelegate?.onResult(requestCode)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        wrappedKeyStore = WrappedKeyStore()
        val keyFileStore = WrappedKeyFileStore(noBackupFilesDir)
        databaseKeyManager = DatabaseKeyManager(wrappedKeyStore, keyFileStore)
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupFilesDir)

        securityChannelHandler = NativeSecurityChannelHandler(
            databasePathProvider = NoBackupDatabasePathProvider(noBackupFilesDir),
            secureWindowController = ::setSecureWindowFlag,
            databaseKeyManager = databaseKeyManager,
            hmacSigner = hmacSigner,
            noBackupFilesDirectory = noBackupFilesDir,
            wrappedKeyStore = wrappedKeyStore,
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeSecurityChannelName)
            .setMethodCallHandler { call, result ->
                when (val response = securityChannelHandler.handle(call.method, call.arguments)) {
                    is NativeChannelResponse.Success -> result.success(response.value)
                    is NativeChannelResponse.Error -> result.error(response.code, response.message, null)
                    NativeChannelResponse.NotImplemented -> result.notImplemented()
                }
            }

        val nativeLogFlutterApi = NativeLogFlutterApi(flutterEngine.dartExecutor.binaryMessenger)
        nativeLogTree = NativeLogTree(nativeLogFlutterApi)
        Timber.plant(nativeLogTree)

        val smsDelegate = SmsPermissionDelegateFactory.create(this)
        smsPermissionDelegate = smsDelegate
        SmsPermissionHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, object : SmsPermissionHostApi {
            override fun currentStatus() = smsDelegate.currentStatus()
            override fun requestReadSms(callback: (Result<TransportSmsPermissionStatus>) -> Unit) {
                smsDelegate.requestReadSms(callback)
            }
            override fun openAppSettings() = smsDelegate.openAppSettings()
        })

        val shareApi = ShareIntentFlutterApi(flutterEngine.dartExecutor.binaryMessenger)
        shareIntentApi = shareApi

        val historyApi = SmsHistoryDelegateFactory.create(this)
        SmsHistoryHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, historyApi)

        if (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0) {
            Timber.plant(Timber.DebugTree())
        }
    }
}
