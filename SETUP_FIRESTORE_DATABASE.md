# 🔥 Cara Membuat Database Firestore di Firebase

Error yang muncul:
```
The database (default) does not exist for project smart-clockin-presensi
```

Ini berarti database Firestore belum dibuat di Firebase Console.

## 📋 Langkah-langkah Membuat Firestore Database:

### 1. Buka Firebase Console

1. Buka browser dan kunjungi: [Firebase Console](https://console.firebase.google.com/)
2. Login dengan akun Google Anda
3. Pilih project: **smart-clockin-presensi**

### 2. Buat Firestore Database

1. Di menu kiri, klik **Firestore Database** (atau **Build** → **Firestore Database**)
2. Jika belum ada database, akan muncul tombol **Create database**
3. Klik **Create database**

### 3. Pilih Mode Database

Pilih salah satu mode:

**✅ Pilih: Native mode** (Recommended untuk aplikasi baru)
- Mode ini menggunakan Firestore (NoSQL document database)
- Cocok untuk aplikasi presensi ini

**❌ Jangan pilih: Datastore mode** (untuk aplikasi legacy)

Klik **Next**

### 4. Pilih Lokasi Database

Pilih lokasi database yang terdekat dengan pengguna:

**Untuk Indonesia, pilih:**
- **asia-southeast2** (Jakarta) - **RECOMMENDED** ✅
- atau **asia-southeast1** (Singapore)

**Catatan:**
- Lokasi tidak bisa diubah setelah dibuat
- Pilih yang terdekat untuk performa terbaik

Klik **Enable**

### 5. Tunggu Proses Setup

- Firebase akan membuat database Firestore
- Proses ini memakan waktu beberapa detik hingga 1-2 menit
- Tunggu sampai muncul pesan "Cloud Firestore has been created"

### 6. Set Security Rules (PENTING!)

Setelah database dibuat, Anda perlu mengatur Security Rules:

1. Klik tab **Rules** di Firestore Database
2. Ganti rules dengan ini (untuk development/testing):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to authenticated users only
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Atau untuk testing, bisa pakai ini (TIDAK AMAN untuk production):
    // match /{document=**} {
    //   allow read, write: if true;
    // }
  }
}
```

3. Klik **Publish**

**⚠️ PERINGATAN:**
- Rules `allow read, write: if true` hanya untuk testing
- Untuk production, gunakan rules yang lebih ketat
- Rules di atas hanya mengizinkan user yang sudah login

### 7. Verifikasi Database

1. Klik tab **Data** di Firestore Database
2. Pastikan database kosong (belum ada collection)
3. Database siap digunakan!

## ✅ Setelah Database Dibuat:

1. **Restart aplikasi** di device/emulator
2. Coba registrasi atau login lagi
3. Data akan tersimpan di Firestore

## 🔍 Verifikasi Data Tersimpan:

1. Buka Firebase Console → Firestore Database → Data
2. Setelah registrasi/login, akan muncul collection:
   - `users` - Data user yang registrasi
   - `attendance` - Data presensi (setelah clock in)
   - `leave_requests` - Permintaan cuti
   - `salary_requests` - Permintaan gaji

## 📱 Test Aplikasi:

1. Jalankan aplikasi: `flutter run`
2. Registrasi akun baru
3. Cek di Firebase Console apakah data muncul di collection `users`

## ⚠️ Troubleshooting:

**Jika masih error setelah membuat database:**
1. Pastikan project ID benar: `smart-clockin-presensi`
2. Pastikan lokasi database sudah dipilih
3. Tunggu beberapa menit untuk propagasi
4. Restart aplikasi
5. Clear cache: `flutter clean` → `flutter pub get` → `flutter run`

---

**Setelah database Firestore dibuat, error akan hilang dan aplikasi bisa menyimpan data!** ✅





