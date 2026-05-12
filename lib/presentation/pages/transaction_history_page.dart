import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- MATIKAN TOMBOL BACK OTOMATIS & MANUAL ---
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.green,
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [Text('Semua Status', style: TextStyle(fontSize: 12)), Icon(Icons.arrow_drop_down, size: 16)]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [Text('Semua Tanggal', style: TextStyle(fontSize: 12)), Icon(Icons.arrow_drop_down, size: 16)]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama Produk: blablablablablabla', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('Total Produk: 199', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
                            child: const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), minimumSize: const Size(0, 30)),
                                child: const Text('Beri Ulasan', style: TextStyle(color: Colors.green, fontSize: 10)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), minimumSize: const Size(0, 30)),
                                child: const Text('Beli Lagi', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}