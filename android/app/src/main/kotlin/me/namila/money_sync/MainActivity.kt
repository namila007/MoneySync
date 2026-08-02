package me.namila.money_sync

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber

class MainActivity : FlutterFragmentActivity() {
    private lateinit var securityChannelHandler: NativeSecurityChannelHandler
    private lateinit var wrappedKeyStore: WrappedKeyStore
    private lateinit var databaseKeyManager: DatabaseKeyManager
    private lateinit var nativeLogTree: NativeLogTree

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AndroidSecureWindowController { enabled ->
            if (enabled) {
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }.setEnabled(true)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        wrappedKeyStore = WrappedKeyStore()
        val keyFileStore = WrappedKeyFileStore(noBackupFilesDir)
        databaseKeyManager = DatabaseKeyManager(wrappedKeyStore, keyFileStore)
        val hmacSigner = HmacSigner(wrappedKeyStore, noBackupFilesDir)

        securityChannelHandler = NativeSecurityChannelHandler(
            databasePathProvider = NoBackupDatabasePathProvider(noBackupFilesDir),
            secureWindowController = AndroidSecureWindowController { enabled ->
                if (enabled) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            },
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

        if (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0) {
            Timber.plant(Timber.DebugTree())
        }
    }
}
