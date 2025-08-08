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

    signingConfigs {
        create("release") {
            // Default values to prevent "not found" errors
            storeFile = file(System.getenv("KEYSTORE_FILE") ?: "release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "password"
            keyAlias = System.getenv("KEY_ALIAS") ?: "alias"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "password"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true  // Enable minification for release
            isShrinkResources = true  // Enable resource shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Add this line
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf("-Xjvm-default=all")
    }

    // Enable core library desugaring if needed by transitive libs
    buildFeatures {
        // Enable desugaring
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.preference:preference-ktx:1.2.1")
    implementation("androidx.legacy:legacy-preference-v14:1.0.0")
}

flutter {
    source = "../.."
}