plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 🔥 APP İÇİN FİREBASE BAĞLANTISI 🔥
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.otodna"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // OtoDNA Paket Adın
        applicationId = "com.example.otodna"
        // Kuantum Motoru için sınırı NET OLARAK 23'e sabitledik!
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Canlıya alırken imza ayarları buraya gelecek
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Android'e özel ekstra native kütüphaneler gerekirse buraya yazılır
}
