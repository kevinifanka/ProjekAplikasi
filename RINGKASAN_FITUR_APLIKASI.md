# RINGKASAN FITUR APLIKASI SMART CLOCK IN PRESENSI

## 📱 FITUR UTAMA

### 1. SISTEM AUTENTIKASI
✅ **Registrasi Akun**
- Input nama lengkap dengan validasi
- Input email dengan validasi format
- Input password (minimal 6 karakter)
- Pilihan departemen/posisi (12 opsi + custom)
- Persetujuan Terms & Conditions
- Data tersimpan ke Firebase Authentication dan Firestore

✅ **Login**
- Login dengan email dan password
- Opsi login dengan fingerprint (biometric)
- Auto-login untuk user yang sudah terdaftar
- Data user diambil dari Firestore secara realtime

### 2. PRESENSI DIGITAL
✅ **Clock In/Out**
- Foto wajah untuk validasi
- GPS tracking lokasi presensi
- Peta lokasi ditampilkan
- Alamat lengkap dari koordinat GPS
- Catatan opsional
- Upload foto ke Firebase Storage
- Data tersimpan ke Firestore dengan departemen sesuai registrasi

### 3. PENGELOLAAN DATA
✅ **Pengajuan Cuti**
- Form lengkap dengan validasi
- Upload lampiran dokumen
- Data tersimpan ke Firestore

✅ **Permintaan Gaji**
- Form dengan format currency
- Pilihan metode pembayaran
- Detail rekening untuk transfer bank
- Upload lampiran dokumen
- Data tersimpan ke Firestore

✅ **Pengajuan Lembur**
- Form pengajuan lembur
- Data tersimpan ke Firestore

✅ **Perubahan Shift**
- Form perubahan shift
- Data tersimpan ke Firestore

### 4. PROFIL KARYAWAN
✅ **Manajemen Profil**
- Tampilkan nama dan email sesuai akun yang login
- Update foto profil
- Upload foto ke Firebase Storage
- Update realtime dari Firestore
- Logout dengan clear data

### 5. DASHBOARD
✅ **Dashboard Utama**
- Header dengan nama user (sesuai akun)
- Menu grid untuk akses cepat
- Daftar karyawan yang sedang bekerja
- Navigasi mudah ke semua fitur

---

## 🔥 INTEGRASI FIREBASE

### Authentication
- ✅ Firebase Authentication untuk login/register
- ✅ Session management otomatis
- ✅ Auto-login untuk user yang sudah terdaftar

### Firestore Database
- ✅ Collection `users` - Data user
- ✅ Collection `attendance` - Data presensi
- ✅ Collection `leave_requests` - Pengajuan cuti
- ✅ Collection `salary_requests` - Permintaan gaji
- ✅ Realtime update untuk data user

### Firebase Storage
- ✅ Upload foto profil
- ✅ Upload foto presensi
- ✅ Upload lampiran dokumen

---

## 📊 STRUKTUR DATA

### Data User (Collection: users)
- nama: Nama karyawan
- email: Email karyawan
- departemen: Departemen/posisi
- position: Posisi (untuk kompatibilitas)
- createdAt: Waktu registrasi
- role: Role user (default: employee)
- photoUrl: URL foto profil

### Data Presensi (Collection: attendance)
- userId: ID user
- employeeName: Nama karyawan
- position: Departemen sesuai registrasi
- isClockIn: Status clock in/out
- timestamp: Waktu presensi
- address: Alamat GPS
- photoUrl: URL foto presensi
- note: Catatan
- locationType: Tipe lokasi (WFO/WFH/Field)

---

## 🎯 ALUR PENGGUNAAN

1. **Registrasi** → Isi form → Data tersimpan ke Firebase → Masuk Dashboard
2. **Login** → Input email/password → Ambil data dari Firebase → Masuk Dashboard
3. **Clock In** → Ambil foto → GPS lokasi → Upload ke Firebase → Data tersimpan
4. **Pengajuan** → Isi form → Upload dokumen → Data tersimpan ke Firebase
5. **Profil** → Update data → Realtime sync dengan Firestore

---

## ✅ KELEBIHAN APLIKASI

1. **Online Storage** - Data tersimpan di Firebase, aman dan tidak hilang
2. **Realtime Update** - Data update otomatis di semua device
3. **Multi-device** - Bisa digunakan di berbagai device dengan akun yang sama
4. **GPS Tracking** - Lokasi presensi tercatat dengan akurat
5. **Foto Presensi** - Validasi dengan foto wajah
6. **User-friendly** - Interface yang mudah digunakan
7. **Departemen Terintegrasi** - Posisi sesuai dengan registrasi

---

## 📱 CARA PENGGUNAAN

### Untuk User Baru:
1. Buka aplikasi
2. Klik "Sign Up" atau "Buat Akun"
3. Isi form registrasi (nama, departemen, email, password)
4. Centang Terms & Conditions
5. Klik "Buat Akun"
6. Otomatis masuk ke Dashboard

### Untuk Clock In:
1. Login ke aplikasi
2. Klik tab "Kehadiran"
3. Ambil foto wajah
4. Sistem mendapatkan lokasi GPS
5. Tambahkan catatan (opsional)
6. Klik "Clock In"
7. Data tersimpan ke Firebase

### Untuk Pengajuan:
1. Dari Dashboard, klik menu yang diinginkan (Cuti/Gaji/Lembur)
2. Isi form dengan lengkap
3. Upload lampiran jika ada
4. Klik submit
5. Data tersimpan ke Firebase dengan status "Menunggu"

---

**Aplikasi sudah siap digunakan secara online dan data akan tersimpan ke Firebase!** ✅




