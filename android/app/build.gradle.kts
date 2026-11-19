import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Reads android/app/google-services.json (kept out of git) for push notifications.
    id("com.google.gms.google-services")
}

// Inside the Gradle script `java` is the Java extension, so File is imported instead of java.io.File.
fun resolveStoreFile(rawPath: String): File {
    val home = System.getProperty("user.home")
    val trimmed = rawPath.trim()
    return when {
        trimmed == "~" -> File(home)
        trimmed.startsWith("~/") || trimmed.startsWith("~\\") ->
            File(home, trimmed.substring(2))
        else -> file(trimmed.replace("\${user.home}", home))
    }
}

// Release signing: android/key.properties (plus optional gitignored key.local.properties / env overrides).
val keyProperties = Properties().apply {
    listOf("key.properties", "key.local.properties").forEach { name ->
        val propsFile = rootProject.file(name)
        if (propsFile.exists()) propsFile.inputStream().use { load(it) }
    }
}
fun signingProp(envKey: String, propKey: String): String? =
    System.getenv(envKey)?.takeIf { it.isNotBlank() } ?: keyProperties.getProperty(propKey)

val releaseStoreFile = signingProp("DAIRA_STORE_FILE", "storeFile")
val releaseStorePassword = signingProp("DAIRA_STORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingProp("DAIRA_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingProp("DAIRA_KEY_PASSWORD", "keyPassword")
val hasReleaseKey = !releaseStoreFile.isNullOrBlank()

android {
    namespace = "com.daira.circles"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.daira.circles"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // dev: test app next to the real one (own id, name, icon and link scheme).
    // prod: the store app.
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appScheme"] = "daira-dev"
            // Slate test icon (src/dev/res), so the two apps are easy to tell apart.
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appScheme"] = "daira"
            manifestPlaceholders["appIcon"] = "@mipmap/launcher_icon"
        }
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKey) {
                storeFile = resolveStoreFile(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Without key.properties a release build is signed with the debug key:
            // fine on your phone, rejected by Google Play (tool/release.ps1 checks this).
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

kotlin { compilerOptions { jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 } }

flutter {
    source = "../.."
}
