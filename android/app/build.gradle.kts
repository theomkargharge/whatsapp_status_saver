plugins {
    id("com.android.application") // apk & aab fine gernete 
    id("kotlin-android") // kotlin support for android
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
   // Flutter Gradle plugin integrates Flutter engine + Dart build system into Android build.
}

android {
    namespace = "com.example.whatsapp_status_saver" // budle id
    compileSdk = 36 // Specifies which Android SDK version the app is compiled against.// Higher compileSdk allows using latest Android APIs.
    ndkVersion = flutter.ndkVersion //Defines Native Development Kit version required for native libraries.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
         //Kotlin bytecode target JVM version.
          // Ensures Kotlin compiles to Java 17 compatible bytecode.
    }

    defaultConfig {
        applicationId = "com.example.whatsapp_status_saver" // Unique identifier for the app on device and Play Store.
        minSdk = flutter.minSdkVersion // Minimum Android version required to run the app.
        targetSdk = 34 // Specifies the Android version the app is designed to run on.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


dependencies {
    implementation("com.google.android.exoplayer:exoplayer:2.19.1")
    implementation("com.google.android.exoplayer:exoplayer-ui:2.19.1")
    implementation("com.google.android.exoplayer:exoplayer-smoothstreaming:2.18.1")
    implementation("androidx.documentfile:documentfile:1.0.1")
}

flutter {
    source = "../.."
}
