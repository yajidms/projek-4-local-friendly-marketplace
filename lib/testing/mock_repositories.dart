// lib/testing/mock_repositories.dart
//
// ⚠️ MODE TESTING — Implementasi mock menggunakan package:faker untuk
// menghasilkan data yang realistis, dinamis, dan berjumlah banyak.
//
//   • 10  Seller  — toko lokal bergaya Jawa Barat
//   • 100 Product — 10 produk per seller, barang kebutuhan sehari-hari
//   • 30  Order   — relasi seller & produk yang benar
//
// File ini HANYA digunakan saat testing UI di main.dart.
// Jangan di-import di luar konteks testing.

import 'package:faker/faker.dart';

import '../domain/entities/index.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/seller_repository.dart';

// ─── Random seed konsisten agar data tidak berubah tiap hot-reload ────────────
final _faker = Faker(seed: 42);
final _rng = _faker.randomGenerator;

// ═══════════════════════════════════════════════════════════════════════════════
// Data Lokal Daerah Jawa Barat — kumpulan kata lokal untuk simulasi nama produk & toko
// ═══════════════════════════════════════════════════════════════════════════════

/// Awalan nama toko lokal Jawa Barat 
const _prefixToko = [
  'Warung Bu', 'Warung Pak', 'Toko Kelontong',
  'Minimart', 'Kios', 'Lapak', 'Toko Bu',
  'Waserda', 'Warung Mang', 'Kedai',
];

/// Nama-nama lokal Sunda / Jawa Barat
const _namaLokal = [
  'Sari', 'Dewi', 'Asih', 'Tini', 'Emi', 'Nani',
  'Budi', 'Ade', 'Dodi', 'Yadi', 'Heri', 'Ujang',
  'Acep', 'Agus', 'Dede', 'Neng', 'Eneng', 'Iis',
  'Yanti', 'Rosmini', 'Mimin', 'Endah', 'Euis',
  'Rizky', 'Tatang', 'Ujang', 'Iwan', 'Siti'
  'Aboy', 'Otang', 'Uca', 'Abi','Aceng', 'Abah'
];

/// Deskripsi toko lokal
const _deskripsiToko = [
  'Menyediakan kebutuhan sehari-hari warga sekitar',
  'Warung lengkap sembako dan produk lokal berkualitas',
  'Melayani dengan ramah, harga terjangkau untuk semua',
  'Pusat belanja kebutuhan dapur dan rumah tangga',
  'Produk segar langsung dari petani lokal Jawa Barat',
  'Warung kelontong terpercaya sejak 2010',
  'Stok selalu tersedia, harga bersahabat',
  'Tersedia aneka produk UMKM dan produk lokal unggulan',
];

/// Alamat jalan lokal Jawa Barat
const _jalanLokal = [
  'Jl. Raya Cibiru', 'Jl. Soekarno Hatta', 'Jl. Pasteur',
  'Jl. Cimahi Raya', 'Jl. Dago Asri', 'Jl. Sudirman',
  'Jl. Moh. Toha', 'Jl. Cicadas', 'Jl. Kopo Mas',
  'Jl. Pelajar Pejuang', 'Jl. Ibrahim Adjie', 'Jl. Antapani',
  'Jl. Cikutra', 'Jl. Sunda', 'Jl. Asia Afrika',
  'Jl. Cibaduyut', 'Jl. Cimahi', 'Jl. Bogor', 
  'Jl. Kebon Jeruk', 'Jl. Kuningan', 'Jl. Lebak Bulus'
];

/// Kelurahan Jawa Barat
const _kelurahan = [
  'Sukasari', 'Cibeunying', 'Antapani', 'Arcamanik',
  'Cinambo', 'Cibiru', 'Mandalajati', 'Ujungberung',
  'Rancasari', 'Bandung Kidul', 'Bojongloa', 'Astana Anyar',
  'Ciparay', 'Cicalengka', 'Cikao', 'Cicendo',
  'Cibaduyut', 'Cimahi', 'Bogor', 'Kebon Jeruk', 'Kuningan', 'Lebak Bulus'
];

/// Kota/Kabupaten Jawa Barat
const _kota = [
  'Bandung', 'Cimahi', 'Bogor', 'Bekasi',
  'Depok', 'Sukabumi', 'Cianjur', 'Garut',
  'Tasikmalaya', 'Sumedang',
  'Cianjur', 'Ciamis', 'Cirebon', 'Kuningan', 
  'Pangandaran', 'Purwakarta', 'Subang', 'Karawang',
  'Majalengka', 'Kab.Bandung Barat','Kab.Bandung','Kab.Cirebon','Kab.Kuningan'
];


/// Template nama produk lokal kebutuhan sehari-hari
/// Format: [nama produk, kategori]
const _katalogProduk = [
  // Sembako
  ['Beras Premium 5kg', 'Sembako'],
  ['Beras Cianjur Pulen 10kg', 'Sembako'],
  ['Minyak Goreng Tropical 2L', 'Sembako'],
  ['Gula Pasir 1kg', 'Sembako'],
  ['Gula Aren Jawa 500g', 'Sembako'],
  ['Telur Ayam Kampung 1 Papan', 'Sembako'],
  ['Tepung Terigu Cakra 1kg', 'Sembako'],
  ['Garam Dapur 250g', 'Sembako'],
  ['Mi Instan Goreng (renceng)', 'Sembako'],
  ['Kecap Manis Bango 275ml', 'Sembako'],
  ['Kentang Pangalengan 1kg', 'Sembako'],
  ['Bawang Merah Garut 1kg', 'Sembako'],
  ['Bawang Putih 1kg', 'Sembako'],
  ['Tahu Putih 1/2kg', 'Sembako'],
  ['Tempe Segitiga 1 papan', 'Sembako'],
  ['Tepung Terigu Segitiga Biru 1kg', 'Sembako'],
  ['Tepung Kanji 500gr', 'Sembako'],
  ['Tahu Cibuntu 1/2kg', 'Sembako'],
  ['Tempe Cibuntu 1/2kg', 'Sembako'],
  ['Kulit Tahu 500gr', 'Sembako'],
  ['Tahu Kuning 1/2kg', 'Sembako'],

  // Makanan
  ['Roti Tawar Sari Roti', 'Makanan'],
  ['Selai Kacang 340g', 'Makanan'],
  ['Susu Kental Manis 385g', 'Makanan'],
  ['Sardines ABC 155g', 'Makanan'],
  ['Corned Beef Pronas 198g', 'Makanan'],
  ['Madu Hutan Asli 350ml', 'Makanan'],
  ['Keripik Singkong Pedas 200g', 'Makanan'],
  ['Dodol Garut Asli 500g', 'Makanan'],
  ['Kerupuk Seblak Instan 150g', 'Makanan'],
  ['Keripik Kentang Kanzler 180g', 'Makanan'],
  ['Indomie Goreng Jumbo 1 pcs', 'Makanan'],
  ['Biskuit Roma Kelapa', 'Makanan'],
  ['Sardines Botan 155g', 'Makanan'],
  ['Mie Sedaap Goreng 1 pcs', 'Makanan'],

  // Minuman
  ['Teh Celup Sosro (kotak)', 'Minuman'],
  ['Air Mineral Aqua 600ml', 'Minuman'],
  ['Minuman Isotonik Pocari 350ml', 'Minuman'],
  ['Jus Buah Siap Minum 250ml', 'Minuman'],
  ['Soda Gembira (botol)', 'Minuman'],
  ['Teh Poci Jahe 200g', 'Minuman'],
  ['Sirup Marjan Melon 460ml', 'Minuman'],
  ['Kopi Susu Kalengan 189ml', 'Minuman'],
  ['Teh Pucuk Harum 350ml', 'Minuman'],
  ['Kopi Torabika Jahe 200g', 'Minuman'],
  ['Teh Botol Sosro 350ml', 'Minuman'],
  ['Air Mineral Prim-a 1500ml', 'Minuman'],
  ['Ale-ale 250ml', 'Minuman'],
  ['Air Mineral Prim-a 600ml', 'Minuman'],
  ['Air Le Minerale 600ml', 'Minuman'],
  ['Air Le Minerale 200ml', 'Minuman'],
  ['Air Mineral Aqua 200ml', 'Minuman'],
  ['Nipis Madu 500ml', 'Minuman'],
  ['Cimory Yogurt 200ml', 'Minuman'],
  ['Susu Ultra 200ml', 'Minuman'],
  ['Nutriboost 300ml', 'Minuman'],
  ['Yakult 60ml', 'Minuman'],
  ['Marimas 100g', 'Minuman'],
  ['Nutrisari 500g', 'Minuman'],
  ['Teh Poci 200g', 'Minuman'],
  ['Kopi Kapal Api 200g', 'Minuman'],
  ['Kopi Luwak 200g', 'Minuman'],
  ['Kopi Instan 200g', 'Minuman'],
  ['Kopi Susu Instan 200g', 'Minuman'],

  // Snack & Camilan
  ['Chitato Sapi Panggang 68g', 'Snack & Camilan'],
  ['Biscuit Roma Marie 250g', 'Snack & Camilan'],
  ['Wafer Tango 176g', 'Snack & Camilan'],
  ['Permen Kopiko (toples)', 'Snack & Camilan'],
  ['Kerupuk Udang Bangka 200g', 'Snack & Camilan'],
  ['Makaroni Pedas Homemade 100g', 'Snack & Camilan'],
  ['Keripik Kentang 100g', 'Snack & Camilan'],
  ['Kue Lapis 200g', 'Snack & Camilan'],
  ['Kue Nastar 200g', 'Snack & Camilan'],
  ['Kue Brownies 200g', 'Snack & Camilan'],
  ['Kue Bolu 200g', 'Snack & Camilan'],
  ['Kue Donat 200g', 'Snack & Camilan'],
  ['Lays 60g', 'Snack & Camilan'],
  ['Keripik Tempe 100g', 'Snack & Camilan'],
  ['Keripik Singkong 100g', 'Snack & Camilan'],
  ['Keripik Pisang 100g', 'Snack & Camilan'],
  ['Chiki Balls 60g', 'Snack & Camilan'],
  ['Taro 60g', 'Snack & Camilan'],
  ['Cheetos 60g', 'Snack & Camilan'],
  ['Piattos 60g', 'Snack & Camilan'],
  ['Pringles 150g', 'Snack & Camilan'],
  ['Qtela 60g', 'Snack & Camilan'],
  ['Choco Pie 60g', 'Snack & Camilan'],
  ['Nabati Siip 60g', 'Snack & Camilan'],
  ['Kitkat 47g', 'Snack & Camilan'],
  ['Beng-Beng 50g', 'Snack & Camilan'],
  ['Sari Gandum 130g', 'Snack & Camilan'],

  // Kebersihan
  ['Sabun Mandi Lifebuoy 110g', 'Kebersihan'],
  ['Detergen Rinso Anti Noda 900g', 'Kebersihan'],
  ['Sabun Cuci Piring Sunlight 410ml', 'Kebersihan'],
  ['Tisu Mahkota 2 roll', 'Kebersihan'],
  ['Pewangi Pakaian Molto 800ml', 'Kebersihan'],
  ['Pembalut Softex 10pcs', 'Kebersihan'],
  ['Sabun Detol Bar 100g', 'Kebersihan'],
  ['Shampo Lifebuoy 100ml', 'Kebersihan'],
  ['Sabun Mandi Nuvo 100g', 'Kebersihan'],
  ['Sabun Cuci Piring Mama Lemon 410ml', 'Kebersihan'],
  ['Pembersih Lantai Wipol 800ml', 'Kebersihan'],
  ['Sabun Antiseptik Cair Dettol 250ml', 'Kebersihan'],
  ['Shampo Emeron 170ml', 'Kebersihan'],
  ['Shampo Pantene 170ml', 'Kebersihan'],
  ['Pasta Gigi Pepsodent 190g', 'Kebersihan'],
  ['Sikat Gigi Pepsodent', 'Kebersihan'],
  ['Shampo Sunsilk 170ml', 'Kebersihan'],
  ['Shampo Clear 170ml', 'Kebersihan'],

  // Kesehatan & Kecantikan
  ['Vitamin C 500mg (strip)', 'Kesehatan & Kecantikan'],
  ['Masker Medis 3 ply (kotak)', 'Kesehatan & Kecantikan'],
  ['Minyak Kayu Putih Cap Lang 120ml', 'Kesehatan & Kecantikan'],
  ['Betadine 30ml', 'Kesehatan & Kecantikan'],
  ['Paracetamol 500mg 10 pcs', 'Kesehatan & Kecantikan'],
  ['Paramex 10 pcs', 'Kesehatan & Kecantikan'],
  ['Obat Flu & Batuk Woods 10 pcs', 'Kesehatan & Kecantikan'],
  ['Minyak Zaitun 100ml', 'Kesehatan & Kecantikan'],
  ['Minyak Zaitun 250ml', 'Kesehatan & Kecantikan'],
  ['Fair and Lovely 100g', 'Kesehatan & Kecantikan'],
  ['Ponds 100g', 'Kesehatan & Kecantikan'],
  ['Vaseline 100g', 'Kesehatan & Kecantikan'],
  ['Minyak Kayu Putih Cap Kapak 60ml', 'Kesehatan & Kecantikan'],
  ['Geliga Otot 200ml', 'Kesehatan & Kecantikan'],
  ['Krim Anti Nyamuk Soffell 100ml', 'Kesehatan & Kecantikan'],
  ['Promag 200ml', 'Kesehatan & Kecantikan'],
  ['Curcuma 100ml', 'Kesehatan & Kecantikan'],
  ['Madu TJ 100ml', 'Kesehatan & Kecantikan'],

  // Bumbu Masak
  ['Bumbu Nasi Goreng Sajiku', 'Bumbu Masak'],
  ['Santan Kara 200ml', 'Bumbu Masak'],
  ['Merica Bubuk 50g', 'Bumbu Masak'],
  ['Bawang Goreng Bawang Mas 100g', 'Bumbu Masak'],
  ['Terasi Udang 50g', 'Bumbu Masak'],
  ['Kunyit Bubuk 50g', 'Bumbu Masak'],
  ['Kecap ABC Botol Kecil', 'Bumbu Masak'],
  ['Kecap Bango Botol Kecil', 'Bumbu Masak'],
  ['Sasa Tepung Bumbu 200g', 'Bumbu Masak'],
  ['Totole Kaldu Jamur 80g', 'Bumbu Masak'],
  ['Royco Bumbu Instan 20g', 'Bumbu Masak'],
  ['Masako Kaldu Bubuk 20g', 'Bumbu Masak'],
  ['Garam Refina 200g', 'Bumbu Masak'],
  ['Gula Pasir Premium 1kg', 'Bumbu Masak'],
  ['MSG Sasa 200g', 'Bumbu Masak'],
  ['Ladaku Merica Bubuk 20g', 'Bumbu Masak'],
  ['Sasa Santan 200ml', 'Bumbu Masak'],
  ['Indofood Kecap Manis 550ml', 'Bumbu Masak'],
  ['Vanilli Bubuk 10g', 'Bumbu Masak'],
  ['Nutrijell 100g', 'Bumbu Masak'],
  ['Agar-Agar Swallow 100g', 'Bumbu Masak'],
];

/// Harga dalam range realistis per kategori (min, max) dalam Rupiah
const _hargaRange = {
  'Sembako': [5000.0, 150000.0],
  'Makanan': [5000.0, 100000.0],
  'Minuman': [3000.0, 50000.0],
  'Snack & Camilan': [3000.0, 40000.0],
  'Kebersihan': [5000.0, 60000.0],
  'Kesehatan & Kecantikan': [8000.0, 80000.0],
  'Bumbu Masak': [2000.0, 30000.0],
  'Lainnya': [5000.0, 50000.0],
};

/// Deskripsi produk lokal yang realistis
const _deskripsiProduk = [
  'Produk berkualitas, cocok untuk kebutuhan sehari-hari keluarga.',
  'Tersedia dalam kemasan praktis, harga terjangkau.',
  'Produk asli Indonesia, dipilih langsung dari produsen lokal.',
  'Kualitas terjamin, dijual per satuan atau grosir.',
  'Produk segar, stok selalu diperbarui setiap minggu.',
  'Cocok untuk masakan rumahan maupun warung makan.',
  'Pilihan hemat untuk keluarga Indonesia.',
  'Tersedia dalam berbagai ukuran sesuai kebutuhan Anda.',
];

// ═══════════════════════════════════════════════════════════════════════════════
// GENERATOR FUNGSI PEMBANTU
// ═══════════════════════════════════════════════════════════════════════════════

/// Ambil item acak dari list bertipe generik
T _pick<T>(List<T> list) => list[_rng.integer(list.length)];

/// Hasilkan nama toko lokal: "[Prefix] [Nama]"
String _namaTokoLokal() => '${_pick(_prefixToko)} ${_pick(_namaLokal)}';

/// Hasilkan alamat lokal: "Jl. X No.Y, RT Z/RW W, Kel. K, Kota C"
String _alamatLokal() {
  final no = _rng.integer(150, min: 1);
  final rt = _rng.integer(10, min: 1).toString().padLeft(2, '0');
  final rw = _rng.integer(15, min: 1).toString().padLeft(2, '0');
  return '${_pick(_jalanLokal)} No. $no, '
      'RT $rt/RW $rw, '
      'Kel. ${_pick(_kelurahan)}, '
      '${_pick(_kota)}';
}

/// Hasilkan nomor HP Indonesia yang valid (08xx-xxxx-xxxx)
String _nomorHP() {
  final prefixes = ['0811', '0812', '0813', '0821', '0822', '0851', '0852', '0857', '0858', '0878'];
  final prefix = _pick(prefixes);
  final mid = _rng.integer(9999, min: 1000);
  final end = _rng.integer(9999, min: 1000);
  return '$prefix$mid$end';
}

/// Hasilkan harga yang realistis (dibulatkan ke kelipatan 500 Rupiah)
double _harga(String kategori) {
  final range = _hargaRange[kategori] ?? [5000.0, 50000.0];
  final min = range[0].toInt();
  final max = range[1].toInt();
  // Hasilkan nilai di antara min dan max, lalu bulatkan ke kelipatan 500
  final raw = _rng.integer(max, min: min);
  return (raw / 500).round() * 500.0;
}

/// Hasilkan stok dengan distribusi realistis:
///   - ~10% stok habis (0)
///   - ~10% stok rendah (1–4)
///   - ~80% stok normal (5–100)
int _stok() {
  final roll = _rng.integer(100);
  if (roll < 10) return 0;
  if (roll < 20) return _rng.integer(4, min: 1);
  return _rng.integer(100, min: 5);
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA YANG DIGENERATE SEKALI (lazy singleton)
// ═══════════════════════════════════════════════════════════════════════════════

/// 10 seller yang di-generate sekali dan di-cache
final List<Seller> _generatedSellers = _buildSellers();

/// 100 product yang di-generate sekali (10 per seller) dan di-cache
final List<Product> _generatedProducts = _buildProducts(_generatedSellers);

/// 30 order yang di-generate sekali dan di-cache
final List<Order> _generatedOrders =
    _buildOrders(_generatedSellers, _generatedProducts);

// ── Builder: 10 Sellers ──────────────────────────────────────────────────────

List<Seller> _buildSellers() {
  // Daftar kategori dominan per toko (dipilih semi-acak)
  final semuaKategoriKombinasi = [
    ['Sembako', 'Makanan', 'Minuman'],
    ['Makanan', 'Snack & Camilan', 'Minuman'],
    ['Sembako', 'Bumbu Masak', 'Makanan'],
    ['Kebersihan', 'Kesehatan & Kecantikan', 'Sembako'],
    ['Snack & Camilan', 'Minuman', 'Makanan'],
    ['Sembako', 'Bumbu Masak'],
    ['Makanan', 'Minuman'],
    ['Kesehatan & Kecantikan', 'Kebersihan'],
    ['Sembako', 'Makanan', 'Bumbu Masak', 'Minuman'],
    ['Lainnya', 'Sembako', 'Makanan'],
  ];

  return List.generate(10, (i) {
    final sellerId = 'seller-${(i + 1).toString().padLeft(3, '0')}';
    final userId = 'user-${(i + 1).toString().padLeft(3, '0')}';
    // Tanggal daftar tersebar dari 2022 hingga awal 2025
    final tglDaftar = DateTime(2022, _rng.integer(12, min: 1),
        _rng.integer(28, min: 1));

    return Seller(
      id: sellerId,
      userId: userId,
      shopName: _namaTokoLokal(),
      shopDescription: _pick(_deskripsiToko),
      shopAddress: _alamatLokal(),
      shopPhone: _nomorHP(),
      // Ambil kombinasi kategori sesuai indeks (sudah variatif)
      categories: semuaKategoriKombinasi[i % semuaKategoriKombinasi.length],
      rating: double.parse(
          // Rating antara 3.5 dan 5.0: (35..50) / 10
          (_rng.integer(50, min: 35) / 10.0).toStringAsFixed(1)),
      totalReviews: _rng.integer(250, min: 5),
      totalProducts: 10, // 10 produk per seller
      isVerified: _rng.boolean(),
      isActive: true,
      isOnline: _rng.boolean(),
      createdAt: tglDaftar,
      updatedAt: tglDaftar.add(Duration(days: _rng.integer(365))),
      isSynced: true,
    );
  });
}

// ── Builder: 100 Products (10 per seller) ───────────────────────────────────

List<Product> _buildProducts(List<Seller> sellers) {
  final products = <Product>[];
  // Acak urutan katalog produk agar tiap run tidak identik
  final shuffledKatalog = List.of(_katalogProduk)..shuffle();

  for (int s = 0; s < sellers.length; s++) {
    final seller = sellers[s];
    for (int p = 0; p < 10; p++) {
      final globalIdx = (s * 10 + p) % shuffledKatalog.length;
      final katalog = shuffledKatalog[globalIdx];
      final namaProduct = katalog[0];
      final kategori = katalog[1];
      final stok = _stok();
      final prodId =
          'prod-${(s + 1).toString().padLeft(2, '0')}-${(p + 1).toString().padLeft(2, '0')}';
      // Tanggal produk ditambahkan setelah toko daftar
      final tglProduk = seller.createdAt
          .add(Duration(days: _rng.integer(300, min: 1)));

      products.add(Product(
        id: prodId,
        sellerId: seller.id,
        name: namaProduct,
        description: _pick(_deskripsiProduk),
        price: _harga(kategori),
        quantity: stok,
        category: kategori,
        // Produk tidak tersedia jika stok habis
        isAvailable: stok > 0,
        sku: 'SKU-${_rng.integer(99999, min: 10000)}',
        weight: (_rng.integer(5000, min: 50)).toDouble(),
        unit: _pick(['pcs', 'kg', 'liter', 'pak', 'karton', 'lusin']),
        createdAt: tglProduk,
        updatedAt:
            tglProduk.add(Duration(days: _rng.integer(60))),
        isSynced: _rng.boolean(),
        isLocalOnly: false,
      ));
    }
  }
  return products;
}

// ── Builder: 30 Orders ──────────────────────────────────────────────────────

List<Order> _buildOrders(List<Seller> sellers, List<Product> products) {
  final orders = <Order>[];
  // Distribusi status order yang realistis
  final statusPool = [
    OrderStatus.pending,    OrderStatus.pending,
    OrderStatus.confirmed,  OrderStatus.confirmed,
    OrderStatus.processing, OrderStatus.processing,
    OrderStatus.shipped,    OrderStatus.shipped,
    OrderStatus.delivered,  OrderStatus.delivered, OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  for (int i = 0; i < 30; i++) {
    final orderId = 'order-${(i + 1).toString().padLeft(3, '0')}';
    // Pilih seller acak
    final seller = _pick(sellers);
    // Ambil produk milik seller tersebut
    final produkSeller = products
        .where((p) => p.sellerId == seller.id && p.isAvailable)
        .toList();

    // Jika seller tidak punya produk tersedia, skip (jarang terjadi)
    if (produkSeller.isEmpty) continue;

    // 1–3 item per order
    final jumlahItem = _rng.integer(3, min: 1);
    final dipilih = <Product>{};
    while (dipilih.length < jumlahItem && dipilih.length < produkSeller.length) {
      dipilih.add(_pick(produkSeller));
    }

    // Buat OrderItem untuk tiap produk dipilih
    int itemCounter = 1;
    final items = dipilih.map((prod) {
      final qty = _rng.integer(5, min: 1);
      final itemId =
          'item-${(i + 1).toString().padLeft(3, '0')}-$itemCounter';
      itemCounter++;
      return OrderItem(
        id: itemId,
        orderId: orderId,
        productId: prod.id,
        product: prod,
        quantity: qty,
        unitPrice: prod.price,
        subtotal: prod.price * qty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Hitung total dari items
    final subtotal =
        items.fold(0.0, (sum, it) => sum + it.subtotal);
    final shippingCost = _pick([0.0, 5000.0, 8000.0, 10000.0, 12000.0, 15000.0]);
    final total = subtotal + shippingCost;

    // Tanggal order: tersebar 0–30 hari ke belakang
    final daysAgo = _rng.integer(30);
    final createdAt =
        DateTime.now().subtract(Duration(days: daysAgo, hours: _rng.integer(23)));

    orders.add(Order(
      id: orderId,
      userId: 'buyer-${_rng.integer(50, min: 1).toString().padLeft(3, '0')}',
      sellerId: seller.id,
      items: items,
      status: _pick(statusPool),
      subtotal: subtotal,
      tax: 0,
      shippingCost: shippingCost,
      total: total,
      notes: _rng.boolean()
          ? _pick([
              'Mohon dikirim pagi hari',
              'Titip ke tetangga jika tidak ada',
              'Tolong bungkus rapi',
              'Jangan digetok-getok ya kak',
              '',
            ])
          : null,
      createdAt: createdAt,
      updatedAt: createdAt.add(Duration(hours: _rng.integer(48))),
      isSynced: true,
    ));
  }

  // Urutkan terbaru dulu
  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return orders;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK SELLER REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════════

class MockSellerRepository implements SellerRepository {
  // Gunakan seller pertama sebagai "active seller" default
  Seller get _mockSeller => _generatedSellers.first;

  @override
  Future<Seller?> getSellerById(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _generatedSellers.firstWhere((s) => s.id == sellerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Seller>> getAllSellers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_generatedSellers);
  }

  @override
  Future<Seller?> getSellerByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _generatedSellers.firstWhere((s) => s.userId == userId);
    } catch (_) {
      // Fallback ke seller pertama jika userId tidak ditemukan
      return _mockSeller;
    }
  }

  @override
  Future<Seller> createSeller(Seller seller) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return seller.copyWith(
      id: 'seller-${DateTime.now().millisecondsSinceEpoch}',
      isSynced: false,
    );
  }

  @override
  Future<Seller> updateSeller(Seller seller) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return seller.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> updateSellerLocation(
      String sellerId, Location location) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // No-op pada mock
  }

  @override
  Future<void> updateSellerOnlineStatus(
      String sellerId, bool isOnline) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // No-op pada mock
  }

  @override
  Future<List<Seller>> getSellersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _generatedSellers
        .where((s) => s.categories.contains(category))
        .toList();
  }

  @override
  Future<void> deleteSeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No-op pada mock
  }

  @override
  Future<void> syncUnSyncedSellers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op pada mock
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK PRODUCT REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════════

class MockProductRepository implements ProductRepository {
  // Salinan mutable agar operasi CRUD (tambah/edit/hapus) bisa bekerja
  final List<Product> _mockProducts = List.of(_generatedProducts);

  @override
  Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockProducts.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts.where((p) => p.sellerId == sellerId).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts
        .where((p) => p.category == category && p.isAvailable)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _mockProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newProduct = product.copyWith(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      isSynced: false,
      isLocalOnly: true,
    );
    _mockProducts.add(newProduct);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _mockProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      final updated = product.copyWith(updatedAt: DateTime.now());
      _mockProducts[idx] = updated;
      return updated;
    }
    return product;
  }

  @override
  Future<void> updateProductQuantity(
      String productId, int newQuantity) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _mockProducts[idx] =
          _mockProducts[idx].copyWith(quantity: newQuantity);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockProducts.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Product>> getUnSyncedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockProducts.where((p) => !p.isSynced).toList();
  }

  @override
  Future<void> syncProducts() async {
    // Simulasi sinkronisasi — tandai semua produk sebagai tersinkron
    await Future.delayed(const Duration(milliseconds: 1200));
    for (int i = 0; i < _mockProducts.length; i++) {
      _mockProducts[i] = _mockProducts[i].copyWith(
        isSynced: true,
        isLocalOnly: false,
        lastSyncedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_mockProducts);
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    // No-op pada mock — data sudah ada in-memory
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK ORDER REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════════

class MockOrderRepository implements OrderRepository {
  // Salinan mutable agar updateOrderStatus bisa bekerja
  final List<Order> _orders = List.of(_generatedOrders);

  @override
  Future<List<Order>> getOrdersBySeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.sellerId == sellerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      return _orders[idx];
    }
    throw Exception('Order tidak ditemukan: $orderId');
  }

  @override
  Future<List<Order>> getOrdersByStatus(
      String sellerId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders
        .where((o) => o.sellerId == sellerId && o.status == status)
        .toList();
  }
}
