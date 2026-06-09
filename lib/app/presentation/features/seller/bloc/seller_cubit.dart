// File: lib/app/presentation/features/seller/bloc/seller_cubit.dart
//
// Cubit untuk memuat profil penjual dari API menggunakan:
//   1. AuthRepository → getCurrentAuth() untuk mendapatkan userId
//   2. SellerRepository → getSellerByUserId() untuk mendapatkan profil toko
//
// State-nya digunakan oleh SellerDashboardView untuk menginisialisasi
// ProductBloc dan TransactionBloc dengan sellerId yang benar.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/seller.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../domain/repositories/seller_repository.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final AuthRepository authRepository;
  final SellerRepository sellerRepository;

  SellerCubit({
    required this.authRepository,
    required this.sellerRepository,
  }) : super(const SellerInitial());

  /// Muat profil penjual berdasarkan sesi autentikasi yang tersimpan.
  Future<void> muatProfil() async {
    emit(const SellerMemuat());
    try {
      // 1. Ambil sesi autentikasi saat ini
      final auth = await authRepository.getCurrentAuth();
      if (auth == null) {
        emit(const SellerGagal('Sesi tidak ditemukan. Silakan masuk kembali.'));
        return;
      }

      final user = auth.user;

      // 2. Jika user sudah memiliki sellerId yang terhubung, coba langsung
      if (user.sellerId != null && user.sellerId!.isNotEmpty) {
        final seller = await sellerRepository.getSellerById(user.sellerId!);
        if (seller != null) {
          emit(SellerTertampil(seller));
          return;
        }
      }

      // 3. Fallback: cari seller berdasarkan userId
      final seller = await sellerRepository.getSellerByUserId(user.id);
      if (seller != null) {
        emit(SellerTertampil(seller));
        return;
      }

      // 4. Seller belum terdaftar — tampilkan state khusus agar bisa diarahkan
      //    ke halaman registrasi toko.
      emit(const SellerBelumTerdaftar());
    } catch (e) {
      emit(SellerGagal('Gagal memuat profil penjual: ${e.toString()}'));
    }
  }

  /// Perbarui profil setelah pengaturan toko disimpan.
  Future<void> perbaruiProfil(Seller seller) async {
    try {
      final updated = await sellerRepository.updateSeller(seller);
      emit(SellerTertampil(updated));
    } catch (e) {
      // Jika gagal, tetap tampilkan data lama
    }
  }
}
