plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kantin_jawara"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    // ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kantin_jawara"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// tasks.whenTaskAdded {
//     if (name.startsWith("assemble")) {
//         doLast {
//             val buildType = name.removePrefix("assemble").lowercase()
//             val apkDir = file("$buildDir/outputs/apk/$buildType")
//             apkDir.listFiles()?.forEach { file ->
//                 if (file.name.endsWith(".apk")) {
//                     file.renameTo(File(file.parent, "kantin-jawara-$buildType.apk"))
//                 }
//             }
//         }
//     }
// }