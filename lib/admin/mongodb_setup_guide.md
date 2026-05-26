# Panduan Integrasi MongoDB Atlas & Flutter Web

Dokumen ini berisi panduan dan catatan penting terkait cara menghubungkan aplikasi Flutter Web dengan MongoDB Atlas, serta perintah-perintah terminal yang berguna untuk mengakses database secara langsung.

---

## 1. Mengapa Flutter Web Tidak Bisa Terkoneksi Langsung?

Secara default, MongoDB menggunakan *Connection String* yang diawali dengan `mongodb+srv://...` 
Protokol ini membutuhkan koneksi **TCP Socket mentah** agar bisa berfungsi.

**Kendala di Flutter Web:**
Browser (Chrome, Edge, Safari, dll.) **memblokir seluruh koneksi TCP Socket mentah** demi alasan keamanan. Browser hanya mengizinkan komunikasi melalui protokol web standar yaitu **HTTP/HTTPS**. 

Karena Flutter Web berjalan di dalam browser, package database standar (seperti `mongo_dart`) akan *crash* atau gagal karena tidak bisa membuka koneksi TCP.

---

## 2. Solusi Arsitektur

Karena Flutter Web hanya mengerti HTTP/HTTPS, kita membutuhkan sebuah "Jembatan" (API) untuk mengubah HTTP menjadi TCP yang dimengerti MongoDB. Ada dua cara utama:

### Opsi A: Membuat Backend API Sendiri (Paling Direkomendasikan)
- **Konsep:** Kita membangun server terpisah menggunakan Node.js (Express) atau bahasa lain. Server ini berjalan di *background*.
- **Alur Kerja:** Flutter Web ➡️ *HTTP Request* ➡️ Backend Node.js ➡️ *TCP Socket (`mongodb+srv://`)* ➡️ MongoDB Atlas.
- **Kelebihan:** Standar industri, keamanan terjamin (password database tidak terlihat di browser), dan logika bisnis bisa disembunyikan di server.

### Opsi B: Menggunakan Atlas Data API (Tanpa Server)
- **Konsep:** MongoDB Atlas memiliki fitur untuk secara otomatis mengubah databasenya menjadi layanan HTTPS.
- **Alur Kerja:** Flutter Web ➡️ *HTTP Request (`https://data.mongodb-api.com/...`)* ➡️ MongoDB Atlas.
- **Syarat:** Anda harus login ke Dashboard MongoDB Atlas di web, mengaktifkan fitur **Data API**, dan men-generate **API Key**. API Key dan URL ini yang dipanggil langsung oleh aplikasi Flutter.

---

## 3. Perintah Terminal Atlas CLI (Cheatsheet)

Jika Anda ingin melihat isi database Anda langsung melalui Terminal (tanpa GUI atau kode program), Anda bisa menggunakan alat **MongoDB Atlas CLI**.

### 1. Memeriksa Project
Untuk melihat semua project yang ada di akun Anda beserta ID-nya:
```bash
atlas projects list
```

### 2. Memilih Default Project
Agar tidak perlu mengetikkan Project ID berulang-ulang, atur sebagai default:
```bash
atlas config set project_id KODE_PROJECT_ID_ANDA
```
*(Contoh: `atlas config set project_id 69f94d3c42f5155e44d25054`)*

### 3. Memeriksa Cluster
Melihat daftar cluster database yang hidup di dalam project tersebut:
```bash
atlas clusters list
```

### 4. Masuk ke Database (MongoDB Shell)
Untuk masuk ke mode *Command Prompt* khusus database:
```bash
atlas clusters mongosh NamaClusterAnda
```
*(Contoh: `atlas clusters mongosh pade` atau `atlas clusters mongosh Cluster0`)*

---

## 4. Perintah Dasar di Dalam MongoDB Shell (`mongosh`)

Setelah Anda berhasil menjalankan perintah `mongosh` dan terminal Anda berubah menjadi `pade>`, Anda bisa mengetik perintah-perintah berikut:

- `show dbs` 
  > Melihat daftar semua database yang ada.
- `use nama_database` 
  > Beralih atau membuat database baru (misal: `use pade_db`).
- `show collections` 
  > Melihat daftar semua tabel (collection) di database saat ini.
- `db.nama_tabel.find()` 
  > Menampilkan data dari tabel tersebut (misal: `db.users.find()`).
- `db.nama_tabel.insertOne({nama: "Yazid", peran: "Admin"})`
  > Memasukkan data baru ke dalam tabel.
- `exit` atau `quit`
  > Keluar dari MongoDB Shell dan kembali ke terminal biasa.
