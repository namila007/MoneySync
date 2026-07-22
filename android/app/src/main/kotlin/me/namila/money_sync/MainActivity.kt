package me.namila.money_sync

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private lateinit var securityChannelHandler: NativeSecurityChannelHandler

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
        securityChannelHandler = NativeSecurityChannelHandler(
            databasePathProvider = NoBackupDatabasePathProvider(noBackupFilesDir),
            secureWindowController = AndroidSecureWindowController { enabled ->
                if (enabled) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            },
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeSecurityChannelName)
            .setMethodCallHandler { call, result ->
                when (val response = securityChannelHandler.handle(call.method, call.arguments)) {
                    is NativeChannelResponse.Success -> result.success(response.value)
                    is NativeChannelResponse.Error -> result.error(response.code, response.message, null)
                    NativeChannelResponse.NotImplemented -> result.notImplemented()
                }
            }
    }
}
