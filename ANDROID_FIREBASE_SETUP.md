# Setup Firebase untuk Android

## 1. Update android/build.gradle (Project level)

Tambahkan di bagian `dependencies`:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0'
        // ✅ TAMBAHKAN INI
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

## 2. Update android/app/build.gradle

Tambahkan di bagian **bawah file** (setelah semua plugin):

```gradle
// ✅ TAMBAHKAN INI DI BAWAH FILE
apply plugin: 'com.google.gms.google-services'
```

## 3. Download google-services.json

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Klik ikon ⚙️ Settings > Project settings
4. Scroll ke bawah ke bagian "Your apps"
5. Klik ikon Android
6. Masukkan package name: `com.example.aplikasi_tugasakhir_presensi`
7. Download `google-services.json`
8. Letakkan file di: `android/app/google-services.json`

## 4. Pastikan repositories sudah ada

Di `android/build.gradle`, pastikan ada:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

## 5. Sync Project

Setelah semua perubahan, sync project:
- Klik "Sync Now" di Android Studio, atau
- Jalankan: `flutter pub get`





