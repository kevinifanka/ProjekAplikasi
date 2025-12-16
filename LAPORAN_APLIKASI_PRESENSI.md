# LAPORAN APLIKASI PRESENSI SMART CLOCK IN

## BAB I. PENDAHULUAN

### 1.1 Latar Belakang
Aplikasi Smart Clock In Presensi adalah aplikasi mobile berbasis Flutter yang dirancang untuk memudahkan karyawan dalam melakukan presensi kehadiran secara digital. Aplikasi ini menggunakan teknologi Firebase sebagai backend untuk menyimpan data secara online dan realtime.

### 1.2 Tujuan
Aplikasi ini dibuat dengan tujuan:
- Memudahkan proses presensi karyawan dengan sistem clock in/out digital
- Menyediakan fitur pengajuan cuti, lembur, dan permintaan gaji secara terintegrasi
- Menyimpan data presensi secara online menggunakan Firebase
- Memberikan akses realtime terhadap data kehadiran karyawan

### 1.3 Ruang Lingkup
Aplikasi ini mencakup fitur-fitur:
- Sistem autentikasi (Registrasi dan Login)
- Presensi digital dengan clock in/out
- Pengajuan cuti
- Pengajuan lembur
- Permintaan gaji
- Manajemen profil karyawan
- Dashboard untuk melihat informasi kehadiran

---

## BAB II. SPESIFIKASI TEKNIS

### 2.1 Platform dan Teknologi

**Framework:**
- Flutter (Dart)

**Backend Services:**
- Firebase Authentication (Login/Register)
- Cloud Firestore (Database)
- Firebase Storage (Penyimpanan Foto)

**Dependencies Utama:**
- `firebase_core: ^2.24.2`
- `firebase_auth: ^4.15.3`
- `cloud_firestore: ^4.13.6`
- `firebase_storage: ^11.5.6`
- `shared_preferences` (Penyimpanan data lokal)
- `geolocator` (Lokasi GPS)
- `camera` (Kamera untuk foto presensi)

### 2.2 Arsitektur Aplikasi

Aplikasi menggunakan arsitektur layanan (service architecture) dengan struktur:

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Konfigurasi Firebase
├── services/
│   └── firebase_service.dart    # Service untuk operasi Firebase
├── onboarding/
│   ├── onboarding_screen.dart   # Halaman onboarding
│   ├── register_screen.dart     # Halaman registrasi
│   └── login_screen.dart        # Halaman login
├── halamanfitur/
│   ├── dasboard_screen.dart     # Dashboard utama
│   ├── face_scan_page.dart     # Halaman clock in/out
│   ├── ClockOutResultPage.dart  # Hasil clock in/out
│   ├── permintaancuti_page.dart # Pengajuan cuti
│   ├── permintaan_gaji_page.dart# Permintaan gaji
│   └── profile_screen.dart     # Profil karyawan
```

---

## BAB III. FITUR APLIKASI

### 3.1 Sistem Autentikasi

#### 3.1.1 Registrasi Akun
- **Fitur:**
  - Input nama lengkap
  - Input email
  - Input password (minimal 6 karakter)
  - Pilihan departemen/posisi
  - Persetujuan Terms of Service dan Privacy Policy

- **Validasi:**
  - Format email harus valid
  - Password minimal 6 karakter
  - Nama minimal 2 karakter
  - Departemen wajib dipilih

- **Proses:**
  1. User mengisi form registrasi
  2. Data divalidasi
  3. Akun dibuat di Firebase Authentication
  4. Data user disimpan ke Firestore (collection `users`)
  5. Data disimpan ke SharedPreferences untuk akses cepat
  6. Redirect ke dashboard

#### 3.1.2 Login
- **Fitur:**
  - Login dengan email dan password
  - Opsi login dengan fingerprint (biometric)
  - Auto-login jika sudah pernah login

- **Proses:**
  1. User input email dan password
  2. Autentikasi dengan Firebase Authentication
  3. Ambil data user dari Firestore
  4. Simpan data ke SharedPreferences
  5. Redirect ke dashboard

### 3.2 Dashboard

Dashboard menampilkan:
- **Header:**
  - Nama user (sesuai akun yang login)
  - Status verifikasi
  - Logo aplikasi

- **Menu Grid:**
  - Cuti (Pengajuan cuti)
  - Lembur (Pengajuan lembur)
  - Hadir Manual (Kehadiran manual)
  - Perubahan Shift
  - Permintaan Gaji
  - HRD Admin (Dashboard admin)

- **Daftar Karyawan:**
  - List karyawan yang sedang bekerja
  - Status clock in/out
  - Waktu presensi

### 3.3 Presensi Digital (Clock In/Out)

#### 3.3.1 Fitur Clock In/Out
- **Deteksi Wajah:**
  - Menggunakan kamera untuk mengambil foto
  - Validasi dengan deteksi wajah

- **Lokasi GPS:**
  - Mendapatkan koordinat GPS saat clock in/out
  - Menampilkan alamat lengkap
  - Peta lokasi presensi

- **Foto Presensi:**
  - Foto wajah saat clock in/out
  - Upload ke Firebase Storage
  - Tersimpan di Firestore

- **Catatan:**
  - Opsi menambahkan catatan saat presensi
  - Catatan tersimpan bersama data presensi

#### 3.3.2 Data yang Disimpan
Setiap clock in/out menyimpan:
- User ID
- Nama karyawan
- Departemen/Posisi (sesuai registrasi)
- Status (Clock In/Clock Out)
- Timestamp
- Alamat GPS
- Koordinat (Latitude, Longitude)
- URL foto presensi
- Catatan (opsional)
- Tipe lokasi (WFO/WFH/Field)

### 3.4 Pengajuan Cuti

- **Form Input:**
  - Jenis cuti (Cuti Tahunan, Cuti Sakit, Cuti Melahirkan, dll)
  - Tanggal mulai
  - Tanggal selesai
  - Jumlah hari (otomatis dihitung)
  - Alasan cuti
  - Lampiran dokumen (opsional)

- **Proses:**
  1. User mengisi form pengajuan
  2. Upload lampiran ke Firebase Storage (jika ada)
  3. Data disimpan ke Firestore (collection `leave_requests`)
  4. Status: "Menunggu" persetujuan

### 3.5 Permintaan Gaji

- **Form Input:**
  - Periode gaji (bulan/tahun)
  - Jumlah gaji
  - Metode pembayaran (Transfer Bank, Tunai, E-Wallet)
  - Detail rekening (jika transfer bank)
  - Alasan permintaan
  - Lampiran dokumen (opsional)

- **Proses:**
  1. User mengisi form permintaan
  2. Upload lampiran ke Firebase Storage (jika ada)
  3. Data disimpan ke Firestore (collection `salary_requests`)
  4. Status: "Menunggu" persetujuan

### 3.6 Profil Karyawan

- **Informasi yang Ditampilkan:**
  - Nama (realtime dari Firestore)
  - Email (realtime dari Firestore)
  - Foto profil
  - Status verifikasi

- **Fitur:**
  - Update foto profil
  - Upload foto ke Firebase Storage
  - Data update realtime dari Firestore
  - Logout

---

## BAB IV. STRUKTUR DATABASE FIREBASE

### 4.1 Cloud Firestore Collections

#### 4.1.1 Collection: `users`
Menyimpan data user yang terdaftar.

**Struktur Document:**
```json
{
  "nama": "Nama Karyawan",
  "email": "email@example.com",
  "departemen": "IT/Technology",
  "position": "IT/Technology",
  "createdAt": "timestamp",
  "role": "employee",
  "photoUrl": "url_foto_profil" (opsional)
}
```

#### 4.1.2 Collection: `attendance`
Menyimpan data presensi karyawan.

**Struktur Document:**
```json
{
  "userId": "user_id_dari_firebase_auth",
  "employeeName": "Nama Karyawan",
  "position": "IT/Technology",
  "isClockIn": true/false,
  "timestamp": "server_timestamp",
  "address": "Alamat lengkap dari GPS",
  "photoUrl": "url_foto_presensi",
  "note": "Catatan" (opsional),
  "locationType": "WFO"
}
```

#### 4.1.3 Collection: `leave_requests`
Menyimpan pengajuan cuti karyawan.

**Struktur Document:**
```json
{
  "userId": "user_id",
  "employeeName": "Nama Karyawan",
  "jenisCuti": "Cuti Tahunan",
  "tanggalMulai": "timestamp",
  "tanggalSelesai": "timestamp",
  "jumlahHari": 3,
  "alasan": "Alasan cuti",
  "attachmentUrls": ["url1", "url2"],
  "status": "Menunggu",
  "createdAt": "server_timestamp"
}
```

#### 4.1.4 Collection: `salary_requests`
Menyimpan permintaan gaji karyawan.

**Struktur Document:**
```json
{
  "userId": "user_id",
  "employeeName": "Nama Karyawan",
  "periode": "timestamp",
  "jumlahGaji": 5000000,
  "metodePembayaran": "Transfer Bank",
  "bank": "BCA",
  "nomorRekening": "1234567890",
  "namaRekening": "Nama Pemilik Rekening",
  "alasan": "Alasan permintaan",
  "attachmentUrls": ["url1", "url2"],
  "status": "Menunggu",
  "createdAt": "server_timestamp"
}
```

### 4.2 Firebase Storage

**Struktur Folder:**
```
profile_images/
  └── {userId}/
      └── {timestamp}.jpg

attendance/
  └── {userId}/
      └── {timestamp}.jpg

leave_requests/
  └── {userId}/
      └── {timestamp}.jpg

salary_requests/
  └── {userId}/
      └── {timestamp}.jpg
```

---

## BAB V. ALUR PENGGUNAAN APLIKASI

### 5.1 Alur Registrasi dan Login

1. **Onboarding Screen**
   - User melihat halaman pengenalan aplikasi
   - Klik "Mulai Sekarang" atau "Lewati"

2. **Halaman Registrasi**
   - User mengisi:
     - Nama lengkap
     - Departemen/posisi
     - Email
     - Password
   - Centang Terms & Conditions
   - Klik "Buat Akun"
   - Data tersimpan ke Firebase
   - Redirect ke Dashboard

3. **Halaman Login** (jika sudah punya akun)
   - Input email dan password
   - Klik "Log In" atau gunakan fingerprint
   - Data user diambil dari Firestore
   - Redirect ke Dashboard

### 5.2 Alur Presensi (Clock In/Out)

1. **Dashboard**
   - User klik tab "Kehadiran" atau menu clock in

2. **Halaman Clock In**
   - Aplikasi meminta izin kamera dan lokasi
   - User mengambil foto wajah
   - Sistem mendapatkan lokasi GPS
   - User bisa menambahkan catatan (opsional)

3. **Konfirmasi Clock In**
   - Tampilkan preview foto
   - Tampilkan peta lokasi
   - Tampilkan alamat
   - User klik "Clock In"

4. **Proses Penyimpanan**
   - Upload foto ke Firebase Storage
   - Simpan data presensi ke Firestore
   - Simpan status clock in ke SharedPreferences
   - Tampilkan konfirmasi sukses

5. **Clock Out**
   - Proses sama dengan clock in
   - Status berubah menjadi "Clock Out"

### 5.3 Alur Pengajuan Cuti

1. **Dashboard**
   - User klik menu "Cuti"

2. **Form Pengajuan Cuti**
   - Pilih jenis cuti
   - Pilih tanggal mulai dan selesai
   - Jumlah hari otomatis terhitung
   - Input alasan
   - Upload lampiran (opsional)

3. **Submit**
   - Upload lampiran ke Firebase Storage (jika ada)
   - Simpan data ke Firestore
   - Tampilkan konfirmasi
   - Status: "Menunggu" persetujuan

### 5.4 Alur Permintaan Gaji

1. **Dashboard**
   - User klik menu "Permintaan Gaji"

2. **Form Permintaan Gaji**
   - Pilih periode (bulan/tahun)
   - Input jumlah gaji
   - Pilih metode pembayaran
   - Input detail rekening (jika transfer bank)
   - Input alasan
   - Upload lampiran (opsional)

3. **Submit**
   - Upload lampiran ke Firebase Storage (jika ada)
   - Simpan data ke Firestore
   - Tampilkan konfirmasi
   - Status: "Menunggu" persetujuan

---

## BAB VI. KEAMANAN DAN VALIDASI

### 6.1 Autentikasi

- **Firebase Authentication:**
  - Semua user harus login untuk menggunakan aplikasi
  - Password di-hash oleh Firebase
  - Session management otomatis

### 6.2 Security Rules Firestore

**Rules yang Digunakan:**
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

**Penjelasan:**
- Hanya user yang sudah login (authenticated) yang bisa membaca dan menulis data
- Setiap user hanya bisa mengakses data miliknya sendiri

### 6.3 Validasi Input

- **Email:** Format email harus valid
- **Password:** Minimal 6 karakter
- **Nama:** Minimal 2 karakter
- **Departemen:** Wajib dipilih
- **Tanggal:** Validasi tanggal mulai tidak boleh setelah tanggal selesai
- **File Upload:** Validasi format dan ukuran file

---

## BAB VII. FITUR REALTIME

### 7.1 Update Realtime

- **Profile:**
  - Data profile update realtime dari Firestore
  - Perubahan data langsung terlihat di aplikasi

- **Dashboard:**
  - Nama user update sesuai akun yang login
  - Data menyesuaikan dengan user yang sedang aktif

### 7.2 Sinkronisasi Data

- **SharedPreferences:**
  - Menyimpan data user untuk akses cepat
  - Sinkronisasi dengan Firestore

- **Firestore:**
  - Data utama tersimpan di Firestore
  - Dapat diakses dari berbagai device

---

## BAB VIII. KESIMPULAN

### 8.1 Pencapaian

Aplikasi Smart Clock In Presensi telah berhasil dibuat dengan fitur-fitur:

1. ✅ **Sistem Autentikasi Lengkap**
   - Registrasi dengan validasi
   - Login dengan email/password
   - Auto-login untuk user yang sudah terdaftar

2. ✅ **Presensi Digital**
   - Clock in/out dengan foto
   - GPS tracking lokasi
   - Data tersimpan ke Firebase

3. ✅ **Pengajuan Online**
   - Pengajuan cuti
   - Permintaan gaji
   - Upload dokumen pendukung

4. ✅ **Integrasi Firebase**
   - Data tersimpan online
   - Realtime update
   - Backup data otomatis

5. ✅ **Manajemen Profil**
   - Update profil realtime
   - Upload foto profil
   - Data sesuai dengan akun yang login

### 8.2 Kelebihan Aplikasi

- **Online Storage:** Data tersimpan di Firebase, tidak hilang saat uninstall
- **Realtime:** Update data secara realtime
- **Multi-device:** Bisa digunakan di berbagai device dengan akun yang sama
- **GPS Tracking:** Lokasi presensi tercatat dengan akurat
- **Foto Presensi:** Validasi dengan foto wajah
- **User-friendly:** Interface yang mudah digunakan

### 8.3 Saran Pengembangan

Untuk pengembangan selanjutnya, dapat ditambahkan:

1. **Notifikasi Push:**
   - Notifikasi approval cuti/gaji
   - Reminder presensi

2. **Laporan:**
   - Laporan kehadiran bulanan
   - Statistik presensi

3. **Admin Dashboard:**
   - Approval pengajuan
   - Manajemen karyawan
   - Laporan kehadiran

4. **Fitur Tambahan:**
   - QR Code untuk presensi
   - Face recognition untuk validasi
   - Export data ke Excel/PDF

---

## LAMPIRAN

### A. Screenshot Aplikasi
*(Tambahkan screenshot dari setiap halaman aplikasi)*

### B. Diagram Alur
*(Tambahkan diagram alur penggunaan aplikasi)*

### C. Struktur Database
*(Tambahkan diagram struktur database Firestore)*

### D. Source Code
*(Referensi ke repository code)*

---

**Dokumen ini menjelaskan secara lengkap tentang aplikasi Smart Clock In Presensi yang telah dibuat dengan integrasi Firebase untuk penyimpanan data online.**

