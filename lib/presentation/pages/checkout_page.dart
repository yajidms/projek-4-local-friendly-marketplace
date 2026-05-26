import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart'; // Import rute aplikasi

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Jl. Pasar Tradisional No. 12, Kelurahan XYZ, Kec. ABC', style: TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
          
          const Text('Item Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Item Dummy', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('1 x Rp. 45.000', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.remove, size: 16), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            const Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.add, size: 16), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          // Metode Pembayaran (Sesuai DC-04: COD Only)
          const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              children: [
                Icon(Icons.handshake, color: Colors.green),
                SizedBox(width: 12),
                Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Upload Bukti Pembayaran (Sesuai UC-003)
          const Text('Bukti Pembayaran (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Lampirkan bukti jika melakukan pembayaran DP.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulasi membuka galeri perangkat...')),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, color: Colors.grey[600], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Tap untuk Upload Gambar',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  const Text('Maks. 500 KB', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          // Total Tagihan
          const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Harga (1 Item)', style: TextStyle(color: Colors.grey)),
              Text('Rp 45.000', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Tagihan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Rp 45.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Tampilkan snackbar konfirmasi sukses membuat entri pesanan awal (FR-029)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulasi pesanan berhasil dibuat!')),
                );

                // 🛠️ TERHUBUNG: Langsung arahkan navigasi ke halaman Riwayat Transaksi pembeli
                Navigator.pushNamed(context, AppRoutes.transaction);
              },
              child: const Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}