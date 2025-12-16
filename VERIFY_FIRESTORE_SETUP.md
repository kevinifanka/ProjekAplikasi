# ✅ Verifikasi Setup Firestore Database

Setelah database Firestore dibuat, ikuti langkah-langkah berikut untuk memastikan semuanya berfungsi:

## 🔍 1. Verifikasi Security Rules

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project: **smart-clockin-presensi**
3. Klik **Firestore Database** → Tab **Rules**
4. Pastikan rules seperti ini:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Klik **Publish** jika belum

## 🔍 2. Verifikasi Database Location

1. Di Firestore Database, klik tab **Data**
2. Pastikan database kosong (belum ada collection)
3. Database siap digunakan!

## 🔍 3. Restart Aplikasi

Jalankan di terminal:

```powershell
cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
flutter clean
flutter pub get
flutter run
```

## 🧪 4. Test Aplikasi

### Test 1: Registrasi
1. Buka aplikasi
2. Klik "Sign Up" atau "Buat Akun"
3. Isi form:
   - Nama: Test User
   - Departemen: Pilih salah satu (misal: IT/Technology)
   - Email: test@example.com
   - Password: minimal 6 karakter
4. Centang Terms & Conditions
5. Klik "Buat Akun"

**Cek di Firebase Console:**
- Firestore Database → Data
- Harus muncul collection `users`
- Klik `users` → harus ada document dengan data user

### Test 2: Login
1. Login dengan email dan password yang baru dibuat
2. Harus berhasil masuk ke dashboard

### Test 3: Clock In
1. Setelah login, klik tab "Kehadiran"
2. Lakukan clock in
3. Isi catatan (opsional)
4. Klik "Clock In"

**Cek di Firebase Console:**
- Collection `attendance` harus muncul
- Harus ada document dengan data presensi
- Field `position` harus sesuai dengan departemen yang dipilih saat registrasi

## ✅ Checklist Verifikasi:

- [ ] Database Firestore sudah dibuat
- [ ] Security Rules sudah diatur dan dipublish
- [ ] Aplikasi sudah di-restart (`flutter clean` → `flutter pub get` → `flutter run`)
- [ ] Registrasi berhasil dan data muncul di Firestore
- [ ] Login berhasil
- [ ] Clock in berhasil dan data muncul di Firestore
- [ ] Departemen/posisi sesuai dengan yang dipilih saat registrasi

## 🐛 Troubleshooting:

### Jika masih error "database does not exist":
1. Pastikan project ID benar: `smart-clockin-presensi`
2. Tunggu 2-3 menit untuk propagasi
3. Restart aplikasi lagi
4. Clear cache: `flutter clean`

### Jika error "Permission denied":
1. Cek Security Rules di Firebase Console
2. Pastikan rules sudah dipublish
3. Pastikan user sudah login (authenticated)

### Jika data tidak muncul di Firestore:
1. Cek koneksi internet
2. Cek apakah ada error di log aplikasi
3. Pastikan Firebase project yang benar
4. Cek apakah Authentication sudah diaktifkan

---

**Jika semua test berhasil, aplikasi sudah siap digunakan!** ✅





