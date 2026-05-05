import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)), // Placeholder Image
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rp. xx xxx xxx xxx', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Mr. Y.\n(misal : Kamera Digital Mini Ultra HD\ndengan Layar Flip Kamera Jempol Portabel)', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Detail Produk (misal : Kamera Digital Mini Ultra HD\ndengan Layar Flip Kamera Jempol Portabel', style: TextStyle(color: Colors.grey)),
                  const Text('Baca Selengkapnya', style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 16),
                  
                  // Info Toko
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.white, radius: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama Toko', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Alamat Toko', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                          onPressed: () {},
                          child: const Text('Ikuti', style: TextStyle(color: Colors.green)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ulasan
                  const Text('Ulasan Pembeli', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.grey, radius: 16),
                      const SizedBox(width: 8),
                      const Text('Mr. Y.'),
                      const SizedBox(width: 8),
                      Row(children: List.generate(4, (index) => const Icon(Icons.star, size: 16))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Sangat Puas mengenai produknya karena because produknya sangat very dan juga and also ini sangat sesuai dengan harga pricenya.', style: TextStyle(fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]!))),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
              child: IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('Masukkan Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}