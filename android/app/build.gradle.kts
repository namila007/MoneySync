plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "me.namila.money_sync"
    compileSdk = 37
    ndkVersion = "30.0.15729638"

    subprojects {
        afterEvaluate {
            extensions.findByName("android")?.let { ext ->
                (ext as com.android.build.gradle.BaseExtension).ndkVersion = "30.0.15729638"
            }
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "me.namila.money_sync"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "distribution"
    productFlavors {
        create("privateFull") {
            dimension = "distribution"
            applicationIdSuffix = ".privatefull"
            versionNameSuffix = "-privateFull"
        }
        create("playManual") {
            dimension = "distribution"
            applicationIdSuffix = ".playmanual"
            versionNameSuffix = "-playManual"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    testImplementation("junit:junit:4.13.2")
    implementation("com.jakewharton.timber:timber:5.0.1")

    androidTestImplementation("androidx.test:core-ktx:1.6.1")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test:rules:1.6.1")
    androidTestImplementation("androidx.test:runner:1.6.2")
}

// M4.0 WP2: a transitive plugin dependency pulls androidx.test:runner/rules into the
// MAIN (non-test) runtime classpath at old versions (1.3.0 / 1.2.0). AGP's "consistent
// resolution" then forces those same old versions onto privateFullDebugAndroidTestRuntimeClasspath,
// conflicting with the androidTestImplementation versions declared above and making
// connectedAndroidTest unresolvable. `force()` is the documented override for a
// `{strictly ...}` constraint from consistent resolution; confirmed via
// `./gradlew :app:dependencyInsight --dependency androidx.test:runner
//   --configuration privateFullDebugAndroidTestRuntimeClasspath`.
configurations.configureEach {
    resolutionStrategy {
        force("androidx.test:runner:1.6.2")
        force("androidx.test:rules:1.6.1")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
