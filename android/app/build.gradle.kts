import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.offmusic.player"
    compileSdk = 34

    defaultConfig {
        // Unique Application ID for OffMusic app
        applicationId = "com.offmusic.player"
        minSdk = 21
        targetSdk = 34
        // Set a concrete integer versionCode; CI previously failed due to a type mismatch.
        // You can later wire this to a value from env or a gradle property if needed.
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: (keystoreProperties["keyAlias"] as? String)
            keyPassword = System.getenv("KEY_PASSWORD") ?: (keystoreProperties["keyPassword"] as? String)
            val storeFilePath = System.getenv("KEYSTORE_FILE") ?: (keystoreProperties["storeFile"] as? String)
            storeFile = storeFilePath?.let { file(it) }
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: (keystoreProperties["storePassword"] as? String)
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf("-Xjvm-default=all")
    }

    // Enable core library desugaring if needed by transitive libs
    buildFeatures {
        // leave defaults
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    // coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
