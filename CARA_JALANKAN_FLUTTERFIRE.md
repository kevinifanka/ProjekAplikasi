# 📍 Cara Menjalankan `flutterfire configure`

## 🎯 **Jalankan di Folder Project Anda**

Perintah `flutterfire configure` harus dijalankan di **folder root project** Flutter Anda.

---

## 📂 **Lokasi Folder Project:**

```
D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi
```

---

## 🚀 **Cara 1: Menggunakan Command Prompt (Windows)**

### Langkah 1: Buka Command Prompt
- Tekan **Windows + R**
- Ketik: `cmd`
- Tekan **Enter**

### Langkah 2: Pindah ke Folder Project
Di Command Prompt, ketik:

```bash
cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
```

**Tekan Enter**

### Langkah 3: Jalankan flutterfire configure
```bash
flutterfire configure
```

**Tekan Enter**

---

## 🚀 **Cara 2: Menggunakan File Explorer (Lebih Mudah)**

### Langkah 1: Buka Folder Project
1. Buka **File Explorer**
2. Navigasi ke: `D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi`
3. Pastikan Anda melihat file `pubspec.yaml` di folder tersebut

### Langkah 2: Buka Command Prompt di Folder Tersebut
1. Klik di **address bar** (tempat path folder)
2. Ketik: `cmd`
3. Tekan **Enter**

**Command Prompt akan terbuka langsung di folder project!**

### Langkah 3: Jalankan flutterfire configure
```bash
flutterfire configure
```

**Tekan Enter**

---

## 🚀 **Cara 3: Menggunakan VS Code / Android Studio**

### Jika menggunakan VS Code:
1. Buka folder project di VS Code
2. Tekan **Ctrl + `** (backtick) untuk buka terminal
3. Terminal sudah otomatis di folder project
4. Ketik: `flutterfire configure`

### Jika menggunakan Android Studio:
1. Buka project di Android Studio
2. Klik tab **Terminal** di bagian bawah
3. Terminal sudah otomatis di folder project
4. Ketik: `flutterfire configure`

---

## ✅ **Cara Cek Apakah Sudah di Folder yang Benar**

Sebelum menjalankan `flutterfire configure`, pastikan Anda di folder yang benar:

```bash
dir
```

Atau:

```bash
ls
```

**Harus terlihat file:**
- ✅ `pubspec.yaml`
- ✅ `lib/` (folder)
- ✅ `android/` (folder)
- ✅ `ios/` (folder)

Jika tidak terlihat, berarti Anda belum di folder project yang benar!

---

## 📋 **Langkah Lengkap:**

1. ✅ Buka Command Prompt
2. ✅ Pindah ke folder project: 
   ```bash
   cd "D:\BACKUP DATA SSD\BACKUP APLIKASI PRESENSI\aplikasi_tugasakhir_presensi"
   ```
3. ✅ Cek folder benar:
   ```bash
   dir
   ```
   (Harus terlihat `pubspec.yaml`)
4. ✅ Jalankan:
   ```bash
   flutterfire configure
   ```
5. ✅ Pilih project Firebase
6. ✅ Pilih platform: Android (Space untuk select, Enter untuk confirm)

---

## 🎯 **Tips:**

- **Gunakan Cara 2** (File Explorer + cmd di address bar) - Paling mudah!
- Pastikan path folder benar (ada spasi di "BACKUP DATA SSD")
- Gunakan tanda kutip `"..."` jika path ada spasi

---

**Pilih salah satu cara di atas, lalu jalankan `flutterfire configure`!** 🚀





