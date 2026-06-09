// File: lib/app/presentation/features/seller/bloc/seller_state.dart

part of 'seller_cubit.dart';

abstract class SellerState extends Equatable {
  const SellerState();
  @override
  List<Object?> get props => [];
}

/// State awal sebelum cubit pertama kali diinisialisasi.
class SellerInitial extends SellerState {
  const SellerInitial();
}

/// Sedang memuat profil penjual dari API / cache.
class SellerMemuat extends SellerState {
  const SellerMemuat();
}

/// Profil penjual berhasil dimuat.
class SellerTertampil extends SellerState {
  final Seller seller;
  const SellerTertampil(this.seller);

  @override
  List<Object?> get props => [seller];
}

/// User belum mendaftar sebagai penjual.
class SellerBelumTerdaftar extends SellerState {
  const SellerBelumTerdaftar();
}

/// Gagal memuat profil penjual.
class SellerGagal extends SellerState {
  final String pesan;
  const SellerGagal(this.pesan);

  @override
  List<Object?> get props => [pesan];
}
