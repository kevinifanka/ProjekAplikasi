# 📱 Cara Build Aplikasi untuk Production (Tanpa USB)

Aplikasi sudah terintegrasi dengan Firebase dan **data akan tersimpan ke Firebase** ketika:
- ✅ Aplikasi terhubung ke internet
- ✅ User sudah login
- ✅ Database Firestore sudah dibuat

## 🚀 Build Aplikasi untuk Production

### 1. Build APK untuk Android

**Jalankan di terminal:**

```powershell
cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
flutter build apk --release
```

**File APK akan ada di:**
```
build/app/outputs/flutter-apk/app-release.apk
```

### 2. Build App Bundle (untuk Google Play Store)

```powershell
flutter build appbundle --release
```

**File AAB akan ada di:**
```
build/app/outputs/bundle/release/app-release.aab
```

### 3. Install APK ke Device

1. Copy file `app-release.apk` ke Android device
2. Install APK di device
3. Buka aplikasi dan test

## ✅ Verifikasi Data Tersimpan ke Firebase

### Test saat Online (dengan Internet):

1. **Registrasi:**
   - Buka aplikasi
   - Registrasi akun baru
   - **Cek di Firebase Console** → Firestore Database → Data
   - Collection `users` harus muncul dengan data user

2. **Clock In:**
   - Login dengan akun yang dibuat
   - Lakukan clock in
   - **Cek di Firebase Console** → Collection `attendance` harus muncul
   - Data presensi harus tersimpan dengan lengkap

3. **Permintaan Cuti/Gaji:**
   - Ajukan permintaan cuti atau gaji
   - **Cek di Firebase Console** → Collection `leave_requests` atau `salary_requests`
   - Data harus tersimpan

## 📊 Data yang Tersimpan ke Firebase:

### ✅ Saat Online (dengan Internet):
- ✅ **Registrasi** → Data user tersimpan di Firestore (`users` collection)
- ✅ **Login** → Data user diambil dari Firestore
- ✅ **Clock In/Out** → Data presensi tersimpan di Firestore (`attendance` collection)
- ✅ **Foto Presensi** → Upload ke Firebase Storage
- ✅ **Permintaan Cuti** → Tersimpan di Firestore (`leave_requests` collection)
- ✅ **Permintaan Gaji** → Tersimpan di Firestore (`salary_requests` collection)
- ✅ **Profile** → Data user realtime dari Firestore

### ⚠️ Saat Offline (tanpa Internet):
- ⚠️ Data akan di-cache lokal (SharedPreferences)
- ⚠️ Data akan tersimpan ke Firestore **setelah koneksi internet kembali**
- ⚠️ Firestore memiliki offline persistence default

## 🔍 Cara Cek Data di Firebase Console:

1. Buka: https://console.firebase.google.com/
2. Pilih project: **smart-clockin-presensi**
3. Klik **Firestore Database** → Tab **Data**
4. Lihat collections:
   - `users` - Data user yang registrasi
   - `attendance` - Data presensi (clock in/out)
   - `leave_requests` - Permintaan cuti
   - `salary_requests` - Permintaan gaji

## 🧪 Test Aplikasi di Device (Tanpa USB):

1. **Install APK** ke device Android
2. **Pastikan device terhubung ke internet** (WiFi atau Data)
3. **Buka aplikasi**
4. **Registrasi akun baru**
5. **Cek di Firebase Console** apakah data muncul
6. **Lakukan clock in**
7. **Cek di Firebase Console** apakah data presensi muncul

## ✅ Checklist Sebelum Release:

- [ ] Database Firestore sudah dibuat
- [ ] Security Rules sudah diatur
- [ ] Aplikasi sudah di-build (`flutter build apk --release`)
- [ ] Test registrasi → data muncul di Firestore
- [ ] Test login → berhasil
- [ ] Test clock in → data muncul di Firestore
- [ ] Test dengan internet → data tersimpan
- [ ] Test tanpa internet → aplikasi tetap bisa digunakan (data cache)

## 📱 Install APK ke Device:

### Cara 1: Via USB (untuk testing)
```powershell
flutter install
```

### Cara 2: Copy Manual
1. Copy file `app-release.apk` ke device
2. Buka file manager di device
3. Tap file APK
4. Install aplikasi

### Cara 3: Via ADB (tanpa USB debugging)
```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## 🔐 Security Rules untuk Production:

**Untuk production, gunakan rules yang lebih ketat:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - hanya bisa read/write data sendiri
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Attendance - hanya bisa read/write data sendiri
    match /attendance/{attendanceId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Leave requests - hanya bisa read/write data sendiri
    match /leave_requests/{requestId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Salary requests - hanya bisa read/write data sendiri
    match /salary_requests/{requestId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

---

**Aplikasi sudah siap digunakan secara online dan data akan tersimpan ke Firebase!** ✅




