package me.namila.money_sync

import android.view.WindowManager
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import java.io.File
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivitySecurityContractTest {
    @Test
    fun financialShellStartsWithSecureWindowAndNoBackupDatabasePath() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.onActivity { activity ->
                assertTrue(
                    activity.window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE != 0,
                )

                val databasePath = NoBackupDatabasePathProvider(activity.noBackupFilesDir).databasePath()
                assertTrue(databasePath.startsWith(activity.noBackupFilesDir.absolutePath + File.separator))
            }
        }
    }
}
