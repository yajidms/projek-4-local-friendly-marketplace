# Panduan Menjalankan PaDe Admin Dashboard (Web)

Dokumen ini berisi panduan teknis langkah demi langkah untuk melakukan instalasi dependensi, menjalankan mode *development*, hingga mengompilasi (build) aplikasi PaDe Admin Dashboard untuk kebutuhan *production*.

---

## 1. Persiapan Awal (Dependencies & Pubspec)

Sebelum menjalankan aplikasi, Anda harus memastikan semua *library* dan *package* yang terdaftar di `pubspec.yaml` sudah terunduh dengan benar.

1. Buka terminal (Command Prompt / PowerShell) dan pastikan Anda berada di dalam folder proyek utama (`projek-4-local-friendly-marketplace`).
2. Jalankan perintah berikut untuk mengunduh semua *dependencies*:
   ```bash
   flutter pub get
   ```
3. *(Opsional)* Jika di masa depan kita menggunakan *library* yang membutuhkan *code generation* (seperti `freezed`, `json_serializable`, atau `bloc`), jalankan perintah ini setelah `pub get`:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

## 2. Menjalankan Mode Development (Testing)

Untuk melihat dan menguji tampilan website secara *real-time* saat Anda melakukan *coding*, gunakan perintah `flutter run`.

1. **Menggunakan Google Chrome:**
   ```bash
   flutter run -d chrome
   ```
2. **Menggunakan Microsoft Edge:**
   ```bash
   flutter run -d edge
   ```
3. **Mengatur Port Spesifik (Disarankan):**
   Agar port tidak berubah-ubah setiap kali Anda me-restart aplikasi (sangat berguna untuk pengaturan API/CORS nanti), tentukan *web port* secara manual:
   ```bash
   flutter run -d chrome --web-port 8080
   ```
   *Setelah berjalan, Anda bisa membuka `http://localhost:8080` di browser Anda.*

> **Tips Saat Development:**
> - Ketik `r` di terminal untuk melakukan **Hot Reload** (memperbarui tampilan UI tanpa merestart state).
> - Ketik `R` di terminal untuk melakukan **Hot Restart** (merestart ulang aplikasi secara penuh).
> - Ketik `q` untuk mematikan server lokal.

---

## 3. Kompilasi untuk Production (Build Web)

Jika aplikasi sudah selesai dan siap untuk di-deploy/di-hosting ke internet (seperti ke Vercel, Firebase Hosting, atau cPanel), Anda harus melakukan *Build*.

1. Jalankan perintah kompilasi web:
   ```bash
   flutter build web
   ```
2. **Hasil Build:**
   Proses ini akan memakan waktu beberapa saat. Setelah sukses, Flutter akan menghasilkan sekumpulan file HTML, CSS, dan JavaScript murni yang sangat optimal. 
   File-file ini akan disimpan di dalam folder:
   📁 `build/web/`
3. Folder `build/web/` inilah yang nantinya di-*upload* ke server hosting Anda.

---

## 4. Troubleshooting Umum (Solusi Masalah)

- **Error: "No file or variants found for asset: .env"**
  > **Solusi:** Pastikan Anda memiliki file bernama `.env` di **folder root/utama** proyek (sejajar dengan `pubspec.yaml`). Jika file `.env` hanya ada di dalam folder `lib/`, copy file tersebut ke luar (ke folder utama).
- **Tampilan Berantakan / Blank Putih setelah Update Code**
  > **Solusi:** Browser seringkali menyimpan *cache* versi lama. Buka *Developer Tools* browser (F12), klik kanan pada tombol *Refresh* di samping URL, lalu pilih **Empty Cache and Hard Reload**.
- **Error: "Target web_release_bundle failed" saat Build**
  > **Solusi:** Biasanya terjadi karena ada aset (gambar/font) di `pubspec.yaml` yang di-referensikan tapi file aslinya tidak ada. Periksa kembali struktur folder `assets/` Anda.
