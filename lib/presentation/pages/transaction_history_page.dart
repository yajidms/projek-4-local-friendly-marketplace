import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Mock List Transaksi yang bervariasi sesuai alur status di SRS (FR-030)
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': 'TRX-20260525-01',
      'productName': 'Beras Premium 5kg',
      'storeName': 'Toko Sembako Pak Budi',
      'quantity': 1,
      'totalPrice': 75000,
      'status': 'Menunggu Verifikasi', // Status awal setelah checkout (FR-029)
      'date': '25 Mei 2026',
    },
    {
      'id': 'TRX-20260524-02',
      'productName': 'Minyak Goreng 2L',
      'storeName': 'Toko Sembako Pak Budi',
      'quantity': 2,
      'totalPrice': 64000,
      'status': 'Diproses', // Status setelah dikonfirmasi Seller (FR-032)
      'date': '24 Mei 2026',
    },
    {
      'id': 'TRX-20260520-03',
      'productName': 'Kaos Polos Cotton',
      'storeName': 'Warung Bu Siti',
      'quantity': 3,
      'totalPrice': 135000,
      'status': 'Selesai', // Status akhir transaksi sukses
      'date': '20 Mei 2026',
    },
  ];

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  // Menentukan warna badge berdasarkan aturan status pesanan di SRS
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Verifikasi':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Siap Diambil':
        return Colors.purple;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
      ),
      body: _mockTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat transaksi', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockTransactions.length,
              itemBuilder: (context, index) {
                final trx = _mockTransactions[index];
                final statusColor = _getStatusColor(trx['status']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID Transaksi & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              trx['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                trx['status'],
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trx['date'],
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Divider(height: 20),

                        // Detail Item Konten
                        Text(
                          trx['productName'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.storefront, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              trx['storeName'],
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Kuantitas (Satuan) & Total Harga
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Menggunakan terminologi "Satuan" sesuai ledger aturan modifikasi data kamu
                            Text(
                              '${trx['quantity']} Satuan',
                              style: TextStyle(color: theme.hintColor, fontSize: 13),
                            ),
                            Text(
                              _formatPrice(trx['totalPrice'].toDouble()),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        // Blok Tombol Aksi Dinamis Kontekstual Sesuai State Use Case SRS
                        if (trx['status'] == 'Menunggu Verifikasi' || trx['status'] == 'Selesai') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Jika pesanan baru dibuat, beri opsi upload bukti transfer (UC-003)
                              if (trx['status'] == 'Menunggu Verifikasi')
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Simulasi melengkapi/upload ulang bukti pembayaran (UC-003)...')),
                                    );
                                  },
                                  icon: const Icon(Icons.cloud_upload, size: 16),
                                  label: const Text('Upload Bukti Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              
                              // Jika pesanan sudah beres, tampilkan fitur ulasan & pembelian ulang
                              if (trx['status'] == 'Selesai') ...[
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Simulasi menuju halaman ulasan produk...')),
                                    );
                                  },
                                  child: const Text('Beri Ulasan', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Produk berhasil ditambahkan kembali ke keranjang belanja!')),
                                    );
                                  },
                                  child: const Text('Beli Lagi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2), // Sesuaikan index navbar untuk Riwayat
    );
  }
}