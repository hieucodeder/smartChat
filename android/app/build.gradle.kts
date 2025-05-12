plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Áp dụng Google Services plugin
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Khai báo biến trong Groovy không cần 'val'
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.aiacademy.smartchat"
    compileSdk = flutter.compileSdkVersion.toInt()  // Thiết lập lại compileSdkVersion từ Flutter
    ndkVersion = "27.0.12077973"  // Cập nhật phiên bản NDK theo yêu cầu

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.aiacademy.smartchat"
        minSdk = 23  // Tăng từ 21 lên 23 theo yêu cầu của Firebase Auth
        targetSdk = flutter.targetSdkVersion.toInt()  // Thiết lập lại targetSdkVersion từ Flutter
        versionCode = flutter.versionCode.toInt()  // Lấy versionCode từ Flutter
        versionName = flutter.versionName  // Lấy versionName từ Flutter
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // Thêm cấu hình để đưa debug symbols vào tệp App Bundle
            ndk.debugSymbolLevel = "FULL"  // Hoặc "SYMBOL_TABLE"
        }
    }
}

flutter {
    source = "../.."  // Đường dẫn tới mã nguồn Flutter
}
