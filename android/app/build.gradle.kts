plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Áp dụng Google Services plugin
    id("dev.flutter.flutter-gradle-plugin")
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

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."  // Đường dẫn tới mã nguồn Flutter
}
