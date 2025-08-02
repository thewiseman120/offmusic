# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Audio Service
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Audio Query
-keep class com.lucasjosino.on_audio_query.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Provider
-keep class com.flutter.provider.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * {*;}

# Keep all methods with @Keep annotation
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Audio focus and media session
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }
