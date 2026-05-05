// File: lib/app/presentation/features/seller/bloc/product_event.dart

part of 'product_bloc.dart';

abstract class ProductEvent {}

/// Muat semua produk milik penjual berdasarkan [sellerId].
class MuatProdukPenjual extends ProductEvent {
  final String sellerId;
  MuatProdukPenjual({required this.sellerId});
}

/// Tambah produk baru ke katalog.
class TambahProduk extends ProductEvent {
  final Product product;
  TambahProduk({required this.product});
}

/// Perbarui data produk yang sudah ada.
class PerbaruiProduk extends ProductEvent {
  final Product product;
  PerbaruiProduk({required this.product});
}

/// Hapus produk berdasarkan ID.
class HapusProduk extends ProductEvent {
  final String productId;
  final String sellerId; // Diperlukan untuk reload daftar setelah hapus
  HapusProduk({required this.productId, required this.sellerId});
}

/// Sinkronkan semua produk yang belum tersinkron ke server.
class SinkronkanProduk extends ProductEvent {
  final String sellerId;
  SinkronkanProduk({required this.sellerId});
}
