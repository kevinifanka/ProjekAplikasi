# 🔧 Cara Memperbaiki Error CONFIGURATION_NOT_FOUND

Error `CONFIGURATION_NOT_FOUND` terjadi karena SHA-1/SHA-256 fingerprint belum ditambahkan di Firebase Console.

## 📋 Langkah-langkah Perbaikan:

### 1. Dapatkan SHA-1 dan SHA-256 Fingerprint

**Cara 1: Menggunakan keytool (RECOMMENDED)**

Buka PowerShell dan jalankan:

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Output yang akan muncul:**
```
Certificate fingerprints:
     SHA1: A1:B2:C3:D4:E5:F6:... (20 pasang hex, dipisah titik dua)
     SHA256: A1:B2:C3:D4:E5:F6:... (32 pasang hex, dipisah titik dua)
```

**⚠️ PENTING - Format yang Benar:**
- ✅ **Benar**: `A1:B2:C3:D4:E5:F6:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE`
- ❌ **Salah**: `SHA1: A1:B2:C3...` (jangan copy kata "SHA1:")
- ❌ **Salah**: `A1 B2 C3...` (jangan ada spasi)
- ❌ **Salah**: `A1B2C3...` (harus ada titik dua)

**Cara Copy yang Benar:**
1. Copy HANYA bagian hex (A1:B2:C3:...)
2. JANGAN copy kata "SHA1:" atau "SHA256:"
3. JANGAN copy spasi di awal atau akhir
4. Pastikan format: `XX:XX:XX:XX:...` (dipisah titik dua, tanpa spasi)

**Cara 2: Menggunakan Gradle**

```powershell
cd android
.\gradlew signingReport
```

Cari di output bagian:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: A1:B2:C3:... (copy ini)
SHA256: A1:B2:C3:... (copy ini)
```

**⚠️ Copy HANYA bagian hex, tanpa kata "SHA1:" atau "SHA256:"**

### 2. Tambahkan SHA-1 dan SHA-256 ke Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project: **smart-clockin-presensi**
3. Klik ikon **⚙️ Settings** (di kiri atas) → **Project settings**
4. Scroll ke bawah ke bagian **Your apps**
5. Klik pada aplikasi Android: **com.example.aplikasi_tugasakhir_presensi**
6. Klik **Add fingerprint** (tombol di samping "SHA certificate fingerprints")
7. **PENTING**: Paste HANYA bagian hex fingerprint
   - ✅ Format: `A1:B2:C3:D4:E5:F6:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE`
   - ❌ JANGAN paste: `SHA1: A1:B2:C3...` (jangan ada kata "SHA1:")
   - ❌ JANGAN paste dengan spasi di awal/akhir
8. Klik **Save**
9. Klik **Add fingerprint** lagi untuk menambahkan SHA-256
10. Paste SHA-256 fingerprint (format sama, tanpa kata "SHA256:")
11. Klik **Save**

**Contoh Format yang Benar:**
- SHA-1: `A1:B2:C3:D4:E5:F6:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE`
- SHA-256: `A1:B2:C3:D4:E5:F6:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA`

### 3. Download ulang google-services.json

1. Setelah menambahkan fingerprint, klik **Download google-services.json**
2. Ganti file `android/app/google-services.json` dengan file yang baru didownload
3. Pastikan file berada di: `android/app/google-services.json`

### 4. Enable Authentication Methods di Firebase

1. Di Firebase Console, buka **Authentication** → **Sign-in method**
2. Pastikan **Email/Password** sudah diaktifkan (Enabled)
3. Jika belum, klik **Email/Password** → **Enable** → **Save**

### 5. Rebuild Aplikasi

```powershell
cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
flutter clean
flutter pub get
flutter run
```

## ⚠️ Catatan Penting:

- **SHA-1 dan SHA-256 harus ditambahkan** sebelum bisa menggunakan Firebase Authentication
- Setelah menambahkan fingerprint, tunggu beberapa menit agar perubahan diterapkan
- Jika masih error, pastikan package name di `android/app/build.gradle` sama dengan yang di Firebase Console

## 🔍 Verifikasi:

Setelah menambahkan fingerprint, cek di Firebase Console:
- **Authentication** → **Settings** → **Authorized domains** harus berisi domain yang benar
- **Project settings** → **Your apps** → Android app harus menampilkan SHA-1 dan SHA-256

## 📱 Alternative: Gunakan Firebase CLI

Jika masih bermasalah, coba generate ulang konfigurasi:

```powershell
cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
flutterfire configure
```

Pilih:
- Project: smart-clockin-presensi
- Platform: Android
- Package name: com.example.aplikasi_tugasakhir_presensi

---

**Setelah semua langkah di atas, error `CONFIGURATION_NOT_FOUND` seharusnya sudah teratasi!** ✅

