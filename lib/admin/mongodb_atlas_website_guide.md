# Panduan Setup Data API via Website MongoDB Atlas

Jika Anda memilih untuk menghubungkan Flutter Web langsung ke MongoDB tanpa membuat backend Node.js, Anda wajib menggunakan fitur **Data API**. 

Berikut adalah langkah-langkah untuk mengaktifkannya melalui website/dashboard MongoDB Atlas:

---

## Langkah 1: Buka Dashboard Atlas
1. Buka web browser Anda dan kunjungi: [https://cloud.mongodb.com/](https://cloud.mongodb.com/)
2. Login menggunakan akun MongoDB Anda.
3. Setelah masuk, pastikan Anda berada di dalam project yang benar (misalnya project **"pade"**). Anda bisa melihat nama project di bagian sudut kiri atas layar.

## Langkah 2: Mengaktifkan Layanan Data API
Data API adalah layanan yang mengubah database Anda menjadi API HTTPS biasa yang bisa dipanggil oleh Flutter Web.

1. Di menu sidebar sebelah kiri, *scroll* ke bawah dan cari bagian **Services**.
2. Klik menu **Data API** (kadang bernama *App Services* atau *Data API*).
3. Anda akan melihat tombol hijau bertuliskan **Enable Data API** (atau **Create Data API App**). Klik tombol tersebut.
4. Akan muncul popup/jendela untuk memilih *Data Source*. Pilih Cluster database Anda (biasanya bernama `Cluster0` atau `pade`).
5. Tunggu sekitar 1-3 menit sampai proses instalasi selesai.
6. Setelah berhasil, Anda akan dialihkan ke halaman utama Data API dan melihat sebuah **URL Endpoint** (contoh: `https://data.mongodb-api.com/app/data-xxxxx/endpoint/data/v1`).
   > ⚠️ **PENTING:** *Copy* URL Endpoint tersebut dan simpan di Notepad. Ini adalah alamat yang akan dihubungi oleh Flutter.

## Langkah 3: Membuat Kunci Akses (API Key)
Database Anda sudah bisa diakses lewat web, tapi tentu saja terkunci. Kita butuh "kunci" agar Flutter bisa masuk.

1. Masih di halaman Data API, perhatikan menu *tab* di bagian atas, lalu klik tab **API Keys**.
2. Klik tombol **Generate API Key**.
3. Beri nama kunci tersebut sesuai keinginan Anda (misal: `AplikasiFlutterWeb`), lalu klik **Generate**.
4. Layar akan memunculkan sebuah string/kode acak yang sangat panjang. 
   > 🚨 **PERINGATAN KRITIS:** *Copy* API Key ini SEKARANG JUGA dan simpan di Notepad. Sama seperti password, API Key ini **hanya ditampilkan SATU KALI**. Jika Anda menutup layarnya tanpa meng-copy-nya, Anda harus menghapusnya dan membuat key yang baru.

## Langkah 4: Hubungkan dengan Flutter (Implementasi)
Setelah Anda memiliki **URL Endpoint** dan **API Key**, masukkan keduanya ke dalam file `.env` di proyek Flutter Anda.

Contoh penambahan di file `lib/.env` Anda:
```env
ATLAS_DATA_API_URL=https://data.mongodb-api.com/app/data-xxxxx/endpoint/data/v1
ATLAS_API_KEY=kunci_panjang_anda_yang_dihasilkan_dari_web
```

Setelah ini disimpan, Anda tinggal memberi tahu saya agar saya bisa membuatkan *script* di dalam Flutter Web untuk mulai menarik dan mendorong data ke database tersebut!
