// Fix for AGP AndroidLocationsException when both ANDROID_PREFS_ROOT and ANDROID_USER_HOME are set
try {
    val peClass = Class.forName("java.lang.ProcessEnvironment")
    val teField = peClass.getDeclaredField("theEnvironment")
    teField.isAccessible = true
    (teField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")

    val tcieField = peClass.getDeclaredField("theCaseInsensitiveEnvironment")
    tcieField.isAccessible = true
    (tcieField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")
} catch (_: Throwable) {}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
