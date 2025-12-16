# 🚀 Setup Firebase - Panduan Sederhana (5 Langkah)

## ✅ TIDAK RIBET! Hanya 5 Langkah Sederhana

---

## 📋 **LANGKAH 1: Install Tools (Sekali Saja)**

### A. Install Node.js (jika belum ada)
- Download dari: https://nodejs.org/
- Install seperti biasa (Next, Next, Finish)

### B. Install Firebase CLI
Buka **Command Prompt** atau **Terminal**, ketik:
```bash
npm install -g firebase-tools
```

### C. Install FlutterFire CLI
Masih di Command Prompt/Terminal:
```bash
dart pub global activate flutterfire_cli
```

**Selesai! Tools sudah terinstall.**

---

## 📋 **LANGKAH 2: Buat Project Firebase (5 Menit)**

1. Buka: https://console.firebase.google.com/
2. Klik **"Add project"** atau **"Tambah project"**
3. Isi nama project (misal: `aplikasi-presensi`)
4. Klik **Continue** → **Continue** → **Create project**
5. Tunggu beberapa detik → **Continue**

**✅ Project Firebase sudah dibuat!**

---

## 📋 **LANGKAH 3: Tambahkan Aplikasi Android (3 Menit)**

1. Di Firebase Console, klik ikon **Android** 📱
2. Isi:
   - **Package name**: `com.example.aplikasi_tugasakhir_presensi`
     (Cek di: `android/app/build.gradle` → `applicationId`)
   - **App nickname**: (opsional, misal: "Presensi App")
   - **Debug signing certificate**: (kosongkan dulu)
3. Klik **Register app**
4. **Download `google-services.json`**
5. **Pindahkan file** ke folder: `android/app/google-services.json`

**✅ File konfigurasi sudah ada!**

---

## 📋 **LANGKAH 4: Setup dengan FlutterFire (2 Menit)**

Buka **Command Prompt/Terminal** di folder project Anda, ketik:

```bash
flutterfire configure
```

Akan muncul pilihan:
- ✅ Pilih project Firebase yang baru dibuat
- ✅ Pilih platform: **Android** (tekan Enter)
- ✅ Pilih platform: **iOS** (opsional, tekan Enter untuk skip jika tidak perlu)

**Selesai!** File `lib/firebase_options.dart` akan otomatis dibuat.

---

## 📋 **LANGKAH 5: Update Kode (3 Menit)**

### A. Update `android/build.gradle`

Buka file: `android/build.gradle`

Cari bagian `dependencies`, tambahkan:
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

Tambahkan di **bawah file** (setelah semua kode):
```gradle
// ✅ TAMBAHKAN DI BAWAH FILE
apply plugin: 'com.google.gms.google-services'
```

### C. Update `lib/main.dart`

Buka file: `lib/main.dart`

Tambahkan di bagian atas (setelah import lainnya):
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

Update fungsi `main()`:
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

### D. Install Dependencies

Di Command Prompt/Terminal:
```bash
flutter pub get
```

---

## ✅ **SELESAI! Firebase Sudah Terhubung!**

### 🧪 **Test Apakah Berhasil**

Jalankan aplikasi:
```bash
flutter run
```

Jika tidak ada error, berarti **Firebase sudah terhubung!** 🎉

---

## 📝 **Ringkasan Waktu**

- **Langkah 1**: 5-10 menit (sekali saja)
- **Langkah 2**: 5 menit
- **Langkah 3**: 3 menit
- **Langkah 4**: 2 menit
- **Langkah 5**: 3 menit

**Total: ~20-25 menit** (untuk pertama kali)

---

## ❓ **Troubleshooting**

### Error: "firebase-tools not found"
```bash
npm install -g firebase-tools
```

### Error: "flutterfire: command not found"
```bash
dart pub global activate flutterfire_cli
# Pastikan PATH sudah benar
```

### Error: "google-services.json not found"
- Pastikan file ada di: `android/app/google-services.json`
- Cek nama file harus persis: `google-services.json`

### Error saat build Android
- Pastikan sudah tambahkan `classpath 'com.google.gms:google-services:4.4.0'` di `android/build.gradle`
- Pastikan sudah tambahkan `apply plugin: 'com.google.gms.google-services'` di `android/app/build.gradle`
- Jalankan: `flutter clean` lalu `flutter pub get`

---

## 🎯 **Kesimpulan**

**TIDAK RIBET!** Hanya:
1. ✅ Install tools (sekali)
2. ✅ Buat project Firebase
3. ✅ Download file konfigurasi
4. ✅ Jalankan `flutterfire configure`
5. ✅ Update beberapa baris kode

**Total waktu: ~20 menit** dan Anda sudah punya backend yang powerful! 🚀

---

## 📚 **Langkah Selanjutnya**

Setelah Firebase terhubung, Anda bisa:
- ✅ Integrasikan login/register dengan Firebase Auth
- ✅ Simpan data presensi ke Firestore
- ✅ Upload foto ke Firebase Storage
- ✅ Kirim notifikasi dengan Cloud Messaging

Lihat file `lib/services/firebase_service.dart` untuk contoh kode yang sudah siap digunakan!





