import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

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
          const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          const Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('n x Rp. xxxxxxxxxxxxx'),
                    const Text('(Ini adalah jumlah item yang dibeli)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.remove, size: 16), constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            const Text('n'),
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
          const SizedBox(height: 8),
          const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 60), // Placeholder space
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          const Text('Total Tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text('Pesan Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}