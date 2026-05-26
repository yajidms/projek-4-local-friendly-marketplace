// File: lib/app/presentation/features/seller/bloc/product_state.dart

part of 'product_bloc.dart';

abstract class ProductState {}

class ProductAwal extends ProductState {}

class ProductMemuat extends ProductState {}

class ProductSedangSinkron extends ProductState {}

class ProductTertampil extends ProductState {
  final List<Product> products;
  /// Jumlah produk yang belum tersinkron (isSynced = false)
  int get jumlahBelumSinkron => products.where((p) => !p.isSynced).length;
  ProductTertampil(this.products);
}

class ProductGagal extends ProductState {
  final String pesan;
  ProductGagal(this.pesan);
}
