import 'dart:math';
import 'package:faker/faker.dart';
import 'package:pade_localfriendly_marketplace/data/models/product_model.dart';

// Fungsi untuk mencetak data dummy secara masif
List<ProductModel> generateFakeProducts(int jumlahData) {
  final faker = Faker();
  final random = Random();
  final List<ProductModel> products = [];

  // Kategori sesuai desain kita
  final categories = ['Sembako', 'Sayuran', 'Elektronik', 'Fashion', 'Kebutuhan Rumah'];
  
  // Wajib pakai 5 seller ini agar koordinat & nama toko di app_router.dart tetap jalan!
  final sellerIds = ['seller_1', 'seller_2', 'seller_3', 'seller_4', 'seller_5'];

  for (var i = 0; i < jumlahData; i++) {
    // Kombinasi kata sifat dan benda biar nama produknya unik
    final adjective = faker.lorem.word();
    final noun = faker.lorem.word();
    final productName = '${adjective[0].toUpperCase()}${adjective.substring(1)} ${noun[0].toUpperCase()}${noun.substring(1)}';

    products.add(
      ProductModel(
        id: faker.guid.guid(),
        sellerId: sellerIds[random.nextInt(sellerIds.length)],
        name: productName, 
        description: faker.lorem.sentences(2).join(' '), // Deskripsi panjang
        price: (random.nextInt(200) + 5) * 1000.0, // Harga acak Rp 5.000 - Rp 204.000
        quantity: random.nextInt(100) + 1, // Stok/jumlah satuan acak 1 - 100
        category: categories[random.nextInt(categories.length)],
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))), // Dibuat 0-30 hari yg lalu
        updatedAt: DateTime.now(),
      ),
    );
  }

  return products;
}


final List<ProductModel> sampleProducts = generateFakeProducts(100);