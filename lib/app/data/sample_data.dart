import 'package:pade_localfriendly_marketplace/data/models/product_model.dart';

final List<ProductModel> sampleProducts = [
  ProductModel(
    id: '1', sellerId: 'seller_1', name: 'Beras Premium 5kg', description: 'Beras premium kualitas terbaik untuk keluarga.', price: 75000, quantity: 50, category: 'Sembako', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '2', sellerId: 'seller_1', name: 'Minyak Goreng 2L', description: 'Minyak goreng sawit jernih.', price: 32000, quantity: 30, category: 'Sembako', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '3', sellerId: 'seller_2', name: 'Kaos Polos Cotton', description: 'Kaos katun halus dan menyerap keringat.', price: 45000, quantity: 20, category: 'Fashion', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '4', sellerId: 'seller_2', name: 'Celana Jeans', description: 'Celana jeans denim tebal dan awet.', price: 120000, quantity: 15, category: 'Fashion', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '5', sellerId: 'seller_3', name: 'Charger HP Universal', description: 'Charger fast charging untuk semua tipe HP.', price: 55000, quantity: 10, category: 'Elektronik', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '6', sellerId: 'seller_3', name: 'Earphone Bluetooth', description: 'Earphone wireless dengan suara jernih.', price: 89000, quantity: 8, category: 'Elektronik', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '7', sellerId: 'seller_4', name: 'Sayur Bayam Segar', description: 'Bayam segar langsung dari petani lokal.', price: 5000, quantity: 100, category: 'Sayuran', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '8', sellerId: 'seller_4', name: 'Tomat 1kg', description: 'Tomat merah segar cocok untuk masakan dan jus.', price: 12000, quantity: 80, category: 'Sayuran', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '9', sellerId: 'seller_5', name: 'Sabun Mandi', description: 'Sabun mandi anti bakteri dan wangi seharian.', price: 8500, quantity: 60, category: 'Kebutuhan Rumah', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: '10', sellerId: 'seller_5', name: 'Detergen 1kg', description: 'Detergen bubuk ampuh angkat noda membandel.', price: 18000, quantity: 45, category: 'Kebutuhan Rumah', createdAt: DateTime.now(), updatedAt: DateTime.now(),
  ),
];