# ✅ Langkah Selanjutnya - Setup Firebase

## Status: Firebase CLI sudah terinstall! 🎉

---

## 📋 **LANGKAH 2: Install FlutterFire CLI**

Buka **Command Prompt** atau **Terminal**, ketik:

```bash
dart pub global activate flutterfire_cli
```

**Tunggu sampai selesai** (sekitar 1-2 menit)

---

## 📋 **LANGKAH 3: Login ke Firebase**

Masih di Command Prompt/Terminal, ketik:

```bash
firebase login
```

Akan terbuka browser untuk login dengan akun Google Anda.
- ✅ Login dengan akun Google
- ✅ Klik "Allow" untuk memberikan akses
- ✅ Kembali ke Command Prompt, akan muncul "Success! Logged in as..."

---

## 📋 **LANGKAH 4: Buat Project Firebase**

1. Buka browser: https://console.firebase.google.com/
2. Klik **"Add project"** atau **"Tambah project"**
3. Isi:
   - **Project name**: `aplikasi-presensi` (atau nama lain)
   - Klik **Continue**
4. **Google Analytics** (opsional):
   - Bisa diaktifkan atau dinonaktifkan
   - Klik **Continue** → **Create project**
5. Tunggu beberapa detik → Klik **Continue**

**✅ Project Firebase sudah dibuat!**

---

## 📋 **LANGKAH 5: Tambahkan Aplikasi Android**

1. Di Firebase Console, klik ikon **Android** 📱 (atau "Add app" → Android)
2. Isi form:
   - **Android package name**: `com.example.aplikasi_tugasakhir_presensi`
     *(Cek di: `android/app/build.gradle` → cari `applicationId`)*
   - **App nickname**: (opsional, misal: "Presensi App")
   - **Debug signing certificate SHA-1**: (kosongkan dulu, untuk development)
3. Klik **Register app**
4. **Download `google-services.json`**
   - Klik tombol download
5. **Pindahkan file** ke folder project:
   - Letakkan di: `android/app/google-services.json`
   - **Pastikan nama file persis**: `google-services.json` (huruf kecil semua)

**✅ File konfigurasi sudah ada!**

---

## 📋 **LANGKAH 6: Setup dengan FlutterFire**

1. Buka **Command Prompt/Terminal**
2. **Pindah ke folder project** Anda:
   ```bash
   cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
   ```
   *(Sesuaikan dengan path project Anda)*

3. Jalankan:
   ```bash
   flutterfire configure
   ```

4. Akan muncul pilihan:
   - **Select a Firebase project**: Pilih project yang baru dibuat (tekan Enter)
   - **Which platforms should be configured?**
     - ✅ **Android** (tekan Enter untuk pilih)
     - ✅ **iOS** (opsional, tekan Enter untuk skip jika tidak perlu)
     - ✅ **Web** (opsional, tekan Enter untuk skip jika tidak perlu)

5. **Selesai!** File `lib/firebase_options.dart` akan otomatis dibuat.

---

## 📋 **LANGKAH 7: Update File Android**

### A. Update `android/build.gradle`

Buka file: `android/build.gradle`

Cari bagian `dependencies` (sekitar line 9-12), tambahkan:

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.1.2'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    // ✅ TAMBAHKAN BARIS INI
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### B. Update `android/app/build.gradle`

Buka file: `android/app/build.gradle`

Scroll ke **bawah file** (setelah semua kode), tambahkan:

```gradle
// ✅ TAMBAHKAN DI BAWAH FILE (baris terakhir)
apply plugin: 'com.google.gms.google-services'
```

---

## 📋 **LANGKAH 8: Update `lib/main.dart`**

Buka file: `lib/main.dart`

### Tambahkan import di bagian atas:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

### Update fungsi `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ TAMBAHKAN INI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp());
}
```

---

## 📋 **LANGKAH 9: Install Dependencies**

Di Command Prompt/Terminal (masih di folder project):

```bash
flutter pub get
```

Tunggu sampai selesai.

---

## ✅ **SELESAI! Test Aplikasi**

Jalankan aplikasi:

```bash
flutter run
```

Jika tidak ada error, berarti **Firebase sudah terhubung!** 🎉

---

## ❓ **Jika Ada Error**

### Error: "firebase_options.dart not found"
- Pastikan sudah jalankan `flutterfire configure`
- Cek apakah file `lib/firebase_options.dart` sudah ada

### Error: "google-services.json not found"
- Pastikan file ada di: `android/app/google-services.json`
- Cek nama file harus persis: `google-services.json` (huruf kecil)

### Error saat build Android
- Pastikan sudah tambahkan `classpath 'com.google.gms:google-services:4.4.0'` di `android/build.gradle`
- Pastikan sudah tambahkan `apply plugin: 'com.google.gms.google-services'` di `android/app/build.gradle`
- Jalankan: `flutter clean` lalu `flutter pub get`

---

## 🎯 **Progress Checklist**

- [x] ✅ Install Firebase CLI
- [ ] ⏳ Install FlutterFire CLI
- [ ] ⏳ Login ke Firebase
- [ ] ⏳ Buat project Firebase
- [ ] ⏳ Download google-services.json
- [ ] ⏳ Jalankan flutterfire configure
- [ ] ⏳ Update android/build.gradle
- [ ] ⏳ Update android/app/build.gradle
- [ ] ⏳ Update lib/main.dart
- [ ] ⏳ Install dependencies
- [ ] ⏳ Test aplikasi

---

**Lanjutkan ke Langkah 2!** 🚀





