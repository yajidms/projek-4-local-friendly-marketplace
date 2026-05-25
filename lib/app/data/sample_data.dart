import '../models/product_model.dart';

final List<ProductModel> sampleProducts = [
  ProductModel(
    id: '1', name: 'Beras Premium 5kg', price: 75000, stock: 50,
    category: 'Sembako', storeName: 'Toko Sembako Pak Budi',
    storeLat: -6.8329, storeLng: 107.5446, // ~0.15km
  ),
  ProductModel(
    id: '2', name: 'Minyak Goreng 2L', price: 32000, stock: 30,
    category: 'Sembako', storeName: 'Toko Sembako Pak Budi',
    storeLat: -6.8329, storeLng: 107.5446,
  ),
  ProductModel(
    id: '3', name: 'Kaos Polos Cotton', price: 45000, stock: 20,
    category: 'Fashion', storeName: 'Warung Bu Siti',
    storeLat: -6.8358, storeLng: 107.5471, // ~0.5km
  ),
  ProductModel(
    id: '4', name: 'Celana Jeans', price: 120000, stock: 15,
    category: 'Fashion', storeName: 'Warung Bu Siti',
    storeLat: -6.8358, storeLng: 107.5471,
  ),
  ProductModel(
    id: '5', name: 'Charger HP Universal', price: 55000, stock: 10,
    category: 'Elektronik', storeName: 'Toko Elektronik Maju',
    storeLat: -6.8401, storeLng: 107.5512, // ~1.2km
  ),
  ProductModel(
    id: '6', name: 'Earphone Bluetooth', price: 89000, stock: 8,
    category: 'Elektronik', storeName: 'Toko Elektronik Maju',
    storeLat: -6.8401, storeLng: 107.5512,
  ),
  ProductModel(
    id: '7', name: 'Sayur Bayam Segar', price: 5000, stock: 100,
    category: 'Sayuran', storeName: 'Pasar Segar Bu Dewi',
    storeLat: -6.8445, storeLng: 107.5489, // ~1.8km
  ),
  ProductModel(
    id: '8', name: 'Tomat 1kg', price: 12000, stock: 80,
    category: 'Sayuran', storeName: 'Pasar Segar Bu Dewi',
    storeLat: -6.8445, storeLng: 107.5489,
  ),
  ProductModel(
    id: '9', name: 'Sabun Mandi', price: 8500, stock: 60,
    category: 'Kebutuhan Rumah', storeName: 'Toko Kelontong Aman',
    storeLat: -6.8489, storeLng: 107.5398, // ~2.5km
  ),
  ProductModel(
    id: '10', name: 'Detergen 1kg', price: 18000, stock: 45,
    category: 'Kebutuhan Rumah', storeName: 'Toko Kelontong Aman',
    storeLat: -6.8489, storeLng: 107.5398,
  ),
];