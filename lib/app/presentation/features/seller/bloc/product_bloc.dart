// File: lib/app/presentation/features/seller/bloc/product_bloc.dart
//
// BLoC untuk manajemen katalog produk penjual.
// Menggunakan ProductRepository (abstract interface) dari domain layer.
// NFR-01: Operasi lokal tidak crash saat offline / Airplane Mode.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/index.dart';
import '../../../../../domain/repositories/product_repository.dart';
import '../../../../utils/image_compressor_util.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductAwal()) {
    on<MuatProdukPenjual>(_onMuat);
    on<TambahProduk>(_onTambah);
    on<PerbaruiProduk>(_onPerbarui);
    on<HapusProduk>(_onHapus);
    on<SinkronkanProduk>(_onSinkron);
  }

  Future<void> _onMuat(
    MuatProdukPenjual event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductMemuat());
    try {
      final products =
          await productRepository.getProductsBySeller(event.sellerId);
      emit(ProductTertampil(products));
    } catch (_) {
      // NFR-01: Fallback ke cache lokal
      try {
        final cached = await productRepository.getCachedProducts();
        emit(ProductTertampil(cached));
      } catch (_) {
        emit(ProductGagal('Gagal memuat produk. Coba lagi nanti.'));
      }
    }
  }

  Future<void> _onTambah(
    TambahProduk event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // NFR-03: Kompres gambar sebelum simpan
      Product product = event.product;
      if (product.images != null && product.images!.isNotEmpty) {
        final compressed =
            await ImageCompressorUtil.compressAndSave(product.images!.first);
        product = product.copyWith(images: [
          compressed,
          ...product.images!.skip(1),
        ]);
      }
      await productRepository.createProduct(product);
      add(MuatProdukPenjual(sellerId: product.sellerId));
    } catch (e) {
      emit(ProductGagal('Gagal menambah produk: ${e.toString()}'));
    }
  }

  Future<void> _onPerbarui(
    PerbaruiProduk event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await productRepository.updateProduct(event.product);
      add(MuatProdukPenjual(sellerId: event.product.sellerId));
    } catch (e) {
      emit(ProductGagal('Gagal memperbarui produk: ${e.toString()}'));
    }
  }

  Future<void> _onHapus(
    HapusProduk event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await productRepository.deleteProduct(event.productId);
      add(MuatProdukPenjual(sellerId: event.sellerId));
    } catch (e) {
      emit(ProductGagal('Gagal menghapus produk: ${e.toString()}'));
    }
  }

  Future<void> _onSinkron(
    SinkronkanProduk event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductSedangSinkron());
    try {
      await productRepository.syncProducts();
    } catch (_) {
      // Sinkronisasi gagal — reload saja; produk tetap ada di lokal
    } finally {
      add(MuatProdukPenjual(sellerId: event.sellerId));
    }
  }
}
