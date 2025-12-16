# Solusi Masalah Ruang Penyimpanan Emulator Android

## Masalah
Error: `android.os.ParcelableException: java.io.IOException: Requested internal only, but not enough space`

Emulator Android kehabisan ruang penyimpanan internal untuk menginstall aplikasi.

## Solusi

### 1. Membersihkan Cache dan Data Emulator (Cara Termudah)

**Melalui Android Studio:**
1. Buka Android Studio
2. Klik menu **Tools** → **Device Manager**
3. Klik ikon **Settings** (⚙️) di samping emulator yang sedang digunakan
4. Klik **Wipe Data** untuk menghapus semua data emulator
5. Atau klik **Cold Boot Now** untuk restart emulator

**Melalui Command Line (jika ADB tersedia):**
```powershell
# Cari lokasi ADB (biasanya di Android SDK)
$env:ANDROID_HOME\platform-tools\adb.exe shell pm clear com.android.providers.downloads
$env:ANDROID_HOME\platform-tools\adb.exe shell pm clear com.android.providers.media
```

### 2. Menghapus Aplikasi yang Tidak Terpakai dari Emulator

**Melalui Emulator:**
1. Buka emulator
2. Buka **Settings** → **Apps**
3. Hapus aplikasi yang tidak terpakai
4. Atau gunakan **Settings** → **Storage** → **Free up space**

**Melalui Android Studio:**
1. Buka **Device Manager**
2. Klik **Settings** pada emulator
3. Klik **Show on Disk**
4. Hapus file cache yang besar

### 3. Membuat Emulator Baru dengan Storage Lebih Besar

1. Buka Android Studio
2. **Tools** → **Device Manager**
3. Klik **Create Device**
4. Pilih device yang diinginkan
5. Klik **Show Advanced Settings**
6. **Internal Storage**: Ubah menjadi minimal **4096 MB** (4 GB)
7. **SD Card**: Tambahkan minimal **1024 MB** (1 GB)
8. Selesai dan jalankan emulator baru

### 4. Menggunakan Emulator yang Lebih Ringan

Jika emulator saat ini terlalu besar, coba:
- Gunakan emulator dengan API level lebih rendah (misalnya API 30 atau 31)
- Pilih system image yang lebih kecil (misalnya tanpa Google Play)

### 5. Membersihkan Build Flutter (Sudah Dilakukan)

```powershell
flutter clean
flutter pub get
```

### 6. Menggunakan Device Fisik (Alternatif)

Jika emulator terus bermasalah:
1. Aktifkan **Developer Options** di device Android
2. Aktifkan **USB Debugging**
3. Sambungkan device ke komputer
4. Jalankan `flutter devices` untuk melihat device
5. Jalankan aplikasi dengan `flutter run`

## Langkah Cepat yang Disarankan

1. **Restart emulator** dengan Cold Boot
2. **Wipe Data** emulator jika masih penuh
3. **Buat emulator baru** dengan storage lebih besar (4GB+)
4. **Coba install lagi** aplikasi

## Catatan

- Emulator membutuhkan minimal 2-3 GB ruang kosong untuk menginstall aplikasi Flutter
- Pastikan komputer memiliki cukup RAM (minimal 8 GB) untuk menjalankan emulator
- Jika masih bermasalah, pertimbangkan menggunakan device fisik atau emulator cloud











