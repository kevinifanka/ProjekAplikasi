# Panduan Integrasi Firebase ke Aplikasi Presensi

## ✅ Aplikasi ini BISA dihubungkan dengan Firebase!

Aplikasi Flutter Anda dapat diintegrasikan dengan Firebase untuk:
- **Firebase Authentication** - Login/Register pengguna
- **Cloud Firestore** - Database untuk menyimpan data presensi, cuti, gaji, dll
- **Firebase Storage** - Menyimpan foto presensi
- **Cloud Messaging** - Notifikasi untuk approval cuti/gaji

---

## 📋 Langkah-langkah Setup Firebase

### 1. Install Firebase CLI (jika belum ada)
```bash
npm install -g firebase-tools
firebase login
```

### 2. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 3. Konfigurasi Firebase di Project
```bash
# Dari root project
flutterfire configure
```

Pilih:
- ✅ Android
- ✅ iOS (jika perlu)
- ✅ Web (jika perlu)

### 4. Tambahkan Dependencies ke pubspec.yaml
Dependencies sudah ditambahkan di file pubspec.yaml

### 5. Download File Konfigurasi
- **Android**: Download `google-services.json` dari Firebase Console
  - Letakkan di: `android/app/google-services.json`
  
- **iOS**: Download `GoogleService-Info.plist` dari Firebase Console
  - Letakkan di: `ios/Runner/GoogleService-Info.plist`

---

## 🔧 Konfigurasi Android

### android/build.gradle
Tambahkan di bagian `dependencies`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### android/app/build.gradle
Tambahkan di bagian bawah file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## 🔧 Konfigurasi iOS

### ios/Podfile
Pastikan versi iOS minimal 11.0:
```ruby
platform :ios, '11.0'
```

Kemudian jalankan:
```bash
cd ios
pod install
```

---

## 📦 Dependencies yang Diperlukan

Dependencies berikut sudah ditambahkan ke `pubspec.yaml`:
- `firebase_core` - Core Firebase
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File Storage
- `firebase_messaging` - Push Notifications

---

## 🚀 Fitur yang Bisa Diintegrasikan

### 1. Authentication (Login/Register)
- ✅ Email/Password authentication
- ✅ Google Sign-In (opsional)
- ✅ Biometric tetap bisa digunakan sebagai 2FA

### 2. Database (Firestore)
- ✅ Data presensi (clock in/out)
- ✅ Data cuti karyawan
- ✅ Data permintaan gaji
- ✅ Data lembur
- ✅ Data perubahan shift

### 3. Storage
- ✅ Foto presensi (clock in/out)
- ✅ Dokumen lampiran cuti/gaji

### 4. Notifications
- ✅ Notifikasi approval cuti
- ✅ Notifikasi approval gaji
- ✅ Reminder presensi

---

## 📝 File yang Perlu Diupdate

Setelah setup Firebase, file berikut perlu diupdate:
1. `lib/main.dart` - Initialize Firebase
2. `lib/onboarding/login_screen.dart` - Integrasi Firebase Auth
3. `lib/onboarding/register_screen.dart` - Integrasi Firebase Auth
4. `lib/halamanfitur/attendance_service.dart` - Integrasi Firestore
5. `lib/halamanfitur/permintaancuti_page.dart` - Simpan ke Firestore
6. `lib/halamanfitur/permintaan_gaji_page.dart` - Simpan ke Firestore

---

## ⚠️ Catatan Penting

1. **Security Rules**: Pastikan setup Firestore Security Rules yang tepat
2. **Quota**: Perhatikan quota Firebase (free tier cukup untuk development)
3. **Offline Support**: Firestore mendukung offline mode secara default
4. **Error Handling**: Tambahkan error handling yang baik untuk semua operasi Firebase

---

## 🔐 Contoh Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users hanya bisa akses data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Attendance records
    match /attendance/{recordId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Leave requests
    match /leave_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

---

## 📚 Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)





