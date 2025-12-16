# Dukungan Kamera Laptop

## Overview
Aplikasi presensi sekarang mendukung penggunaan kamera laptop/desktop sebagai alternatif ketika camera plugin tidak tersedia atau tidak berfungsi dengan baik pada platform desktop.

## Fitur yang Ditambahkan

### 1. Fallback Image Picker
- Ketika camera plugin gagal diinisialisasi pada platform desktop (Windows, macOS, Linux), aplikasi akan otomatis beralih ke image picker
- Image picker menggunakan kamera sistem operasi untuk mengambil foto

### 2. UI Adaptif
- Interface berubah otomatis ketika menggunakan image picker
- Menampilkan tombol "Pilih Foto" untuk mengakses kamera laptop
- Preview gambar yang dipilih ditampilkan di layar

### 3. Simulasi Face Detection
- Untuk image picker, aplikasi mensimulasikan deteksi wajah dengan nilai senyum yang baik (85%)
- Lingkaran indikator berubah menjadi hijau untuk menunjukkan kesiapan foto

## Cara Penggunaan

### Mode Camera Plugin (Default)
1. Aplikasi mencoba menggunakan camera plugin terlebih dahulu
2. Jika berhasil, tampilan kamera real-time akan muncul
3. Deteksi wajah berjalan secara real-time
4. Tekan "Clock In" untuk mengambil foto

### Mode Image Picker (Fallback)
1. Jika camera plugin gagal, aplikasi beralih ke image picker
2. Tampilan berubah menampilkan pesan "Kamera Laptop"
3. Tekan "Pilih Foto" untuk membuka kamera sistem
4. Pilih foto yang diinginkan
5. Tekan "Clock In" untuk menyelesaikan proses

## Platform Support

### Windows
- Camera plugin: ✅ (jika tersedia)
- Image picker: ✅ (fallback)

### macOS
- Camera plugin: ✅ (jika tersedia)
- Image picker: ✅ (fallback)

### Linux
- Camera plugin: ✅ (jika tersedia)
- Image picker: ✅ (fallback)

### Web
- Camera plugin: ✅ (jika tersedia)
- Image picker: ✅ (fallback)

### Android/iOS
- Camera plugin: ✅ (default)
- Image picker: ❌ (tidak digunakan)

## Technical Implementation

### File yang Dimodifikasi
- `lib/halamanfitur/clockin_screen.dart`: Logika utama fallback
- `pubspec.yaml`: Dependency image_picker

### Key Methods
- `_initPermissions()`: Deteksi platform dan inisialisasi
- `_pickImageFromCamera()`: Mengambil foto dari kamera sistem
- `_buildImagePickerView()`: UI untuk mode image picker
- `_capturePhoto()`: Logika capture yang mendukung kedua mode

### State Variables
- `_isUsingImagePicker`: Flag untuk mode image picker
- `_selectedImage`: File gambar yang dipilih
- `_imagePicker`: Instance ImagePicker

## Troubleshooting

### Camera Plugin Tidak Berfungsi
- Aplikasi akan otomatis beralih ke image picker
- Tidak ada tindakan manual yang diperlukan

### Image Picker Tidak Berfungsi
- Pastikan aplikasi memiliki izin kamera
- Restart aplikasi jika diperlukan

### Foto Tidak Tersimpan
- Periksa izin penyimpanan
- Pastikan direktori ClockInPhotos dapat diakses

## Future Improvements
- Implementasi face detection real untuk image picker
- Support untuk multiple camera selection
- Preview real-time untuk image picker mode
- Custom camera interface untuk desktop

