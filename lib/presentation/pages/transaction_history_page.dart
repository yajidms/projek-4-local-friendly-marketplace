import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <-- Pastikan import hive_flutter
import '../widgets/bottom_nav_bar.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  void _showReviewBottomSheet(BuildContext context, String transactionId, {String? existingReview, int existingRating = 0}) {
    final reviewController = TextEditingController(text: existingReview);
    int currentRating = existingRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingReview == null ? 'Beri Ulasan' : 'Edit Ulasan',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bintang Rating (1-5)
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < currentRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: index < currentRating ? Colors.amber : Colors.grey,
                            size: 40,
                          ),
                          onPressed: () {
                            setModalState(() {
                              currentRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kolom Komentar
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ceritain pengalaman kamu beli produk ini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Kirim
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (currentRating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kasih bintangnya dulu dong! ⭐')),
                          );
                          return;
                        }

                        // [CREATE & UPDATE LOGIC] Simpan data ke Hive
                        final box = Hive.box('reviews');
                        box.put(transactionId, {
                          'rating': currentRating,
                          'comment': reviewController.text,
                        });
                        
                        Navigator.pop(context); 
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(existingReview == null 
                                ? 'Ulasan berhasil dikirim (Tersimpan di Lokal)!' 
                                : 'Ulasan berhasil diperbarui!'),
                          ),
                        );
                      },
                      child: const Text(
                        'Kirim Ulasan',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // ==========================================
  // LOGIKA UTAMA: DELETE (HAPUS DATA)
  // ==========================================
  void _deleteReview(BuildContext context, String transactionId) {
    final box = Hive.box('reviews');
    box.delete(transactionId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Ulasan berhasil dihapus!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewBox = Hive.box('reviews'); // Ambil referensi Box Hive

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter status & tanggal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest, 
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Text('Semua Status', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface)), 
                    Icon(Icons.arrow_drop_down, size: 16, color: theme.colorScheme.onSurface), 
                  ]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest, 
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Text('Semua Tanggal', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface)), 
                    Icon(Icons.arrow_drop_down, size: 16, color: theme.colorScheme.onSurface), 
                  ]),
                ),
              ],
            ),
          ),
          
          // List Riwayat Transaksi
          Expanded(
            // [READ LOGIC] Bungkus panyunting dengan ValueListenableBuilder milik Hive
            child: ValueListenableBuilder(
              valueListenable: reviewBox.listenable(),
              builder: (context, Box box, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3, // Dummy 3 transaksi
                  itemBuilder: (context, index) {
                    // Kita buat ID Transaksi unik bayangan berdasarkan indeks-nya
                    final String transactionId = 'tx_00$index';
                    
                    // Cek apakah transaksi ini sudah punya ulasan di Hive
                    final hasReview = box.containsKey(transactionId);
                    final reviewData = hasReview ? Map<String, dynamic>.from(box.get(transactionId)) : null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest, 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.outlineVariant, 
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nama Produk: blablablablablabla ($transactionId)',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)), 
                                    Text('Total Produk: 199',
                                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface)), 
                                    
                                    // Tampilkan rating bintang kecil kalau ulasan sudah ada
                                    if (hasReview) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${reviewData?['rating']} · "${reviewData?['comment']}"',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
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
                                  // JIKA SUDAH ADA ULASAN, MUNCULKAN TOMBOL HAPUS (DELETE)
                                  if (hasReview) ...[
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      onPressed: () => _deleteReview(context, transactionId),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ],

                                  // TOMBOL DINAMIS (BERI ULASAN / EDIT ULASAN)
                                  OutlinedButton(
                                    onPressed: () {
                                      if (hasReview) {
                                        // UPDATE: Lempar data lama ke bottom sheet
                                        _showReviewBottomSheet(
                                          context, 
                                          transactionId,
                                          existingReview: reviewData?['comment'],
                                          existingRating: reviewData?['rating'] ?? 0,
                                        );
                                      } else {
                                        // CREATE: Buka lembaran baru kosong
                                        _showReviewBottomSheet(context, transactionId);
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.green),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        minimumSize: const Size(0, 30)),
                                    child: Text(
                                      hasReview ? 'Edit Ulasan' : 'Beri Ulasan', 
                                      style: const TextStyle(color: Colors.green, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        minimumSize: const Size(0, 30)),
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