# 📋 Format Fingerprint yang Benar untuk Firebase

## ✅ Fingerprint Anda:

**SHA-1:**
```
4E:06:9A:D7:14:16:B1:4B:5F:24:66:B3:A3:65:52:18:0E:B2:DD:D6
```

**SHA-256:**
```
89:0A:D5:18:42:E2:F9:A2:9A:85:17:99:CB:CC:69:84:68:B7:77:BC:7E:1B:F1:B6:A4:8E:2C:0A:EF:D1:A7:8B
```

## ⚠️ PENTING - Format yang Benar:

### ✅ BENAR (Copy ini):
```
4E:06:9A:D7:14:16:B1:4B:5F:24:66:B3:A3:65:52:18:0E:B2:DD:D6
```

### ❌ SALAH (Jangan copy ini):
- `SHA1: 4E:06:9A:D7...` ❌ (jangan copy kata "SHA1:")
- ` 4E:06:9A:D7...` ❌ (jangan copy spasi di awal)
- `4E:06:9A:D7... ` ❌ (jangan copy spasi di akhir)
- `4E 06 9A D7...` ❌ (jangan copy dengan spasi, harus titik dua)
- `4E06:9A:D7...` ❌ (format salah)

## 📝 Cara Copy yang Benar:

1. **Dari output keytool**, copy HANYA bagian hex:
   - SHA-1: `4E:06:9A:D7:14:16:B1:4B:5F:24:66:B3:A3:65:52:18:0E:B2:DD:D6`
   - SHA-256: `89:0A:D5:18:42:E2:F9:A2:9A:85:17:99:CB:CC:69:84:68:B7:77:BC:7E:1B:F1:B6:A4:8E:2C:0A:EF:D1:A7:8B`

2. **JANGAN copy:**
   - Kata "SHA1:" atau "SHA256:"
   - Tab atau spasi di awal
   - Spasi di akhir
   - Baris baru

3. **Format harus:**
   - Dipisah dengan titik dua (`:`)
   - Tanpa spasi
   - Tanpa kata "SHA1:" atau "SHA256:"
   - Hanya hex characters dan titik dua

## 🔧 Langkah di Firebase Console:

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project: **smart-clockin-presensi**
3. Settings → Project settings
4. Scroll ke "Your apps" → Klik aplikasi Android
5. Klik **Add fingerprint**
6. **Paste SHA-1:**
   ```
   4E:06:9A:D7:14:16:B1:4B:5F:24:66:B3:A3:65:52:18:0E:B2:DD:D6
   ```
7. Klik **Save**
8. Klik **Add fingerprint** lagi
9. **Paste SHA-256:**
   ```
   89:0A:D5:18:42:E2:F9:A2:9A:85:17:99:CB:CC:69:84:68:B7:77:BC:7E:1B:F1:B6:A4:8E:2C:0A:EF:D1:A7:8B
   ```
10. Klik **Save**

## ✅ Verifikasi:

Setelah paste, pastikan:
- Tidak ada error "String does not match a recognised certificate fingerprint format"
- Fingerprint muncul di daftar
- Format: `XX:XX:XX:...` (dipisah titik dua, tanpa spasi)

---

**Copy fingerprint di atas dan paste ke Firebase Console!** ✅





