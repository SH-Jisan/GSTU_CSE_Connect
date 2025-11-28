plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // (যদি না থাকে, এটাও দিয়ে দিতে পারো সেইফ সাইড থাকার জন্য)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (manages all Firebase versions)
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Example Firebase products (add only what you need)
//    implementation("com.google.firebase:firebase-analytics")
//    implementation("com.google.firebase:firebase-auth")
//    implementation("com.google.firebase:firebase-firestore")
}
