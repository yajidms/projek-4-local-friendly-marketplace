// File: lib/app/presentation/features/seller/bloc/seller_registration_state.dart

part of 'seller_registration_bloc.dart';

enum StatusRegistrasi { awal, memuat, berhasil, gagal }

class SellerRegistrationState {
  final String namaToko;
  final String kategoriProduk;
  final String? jenisUsaha;
  final String alamatLengkap;
  final String? pathGambarTandaPengenal; // Local file path
  final StatusRegistrasi status;
  final String? pesanError;

  const SellerRegistrationState({
    this.namaToko = '',
    this.kategoriProduk = '',
    this.jenisUsaha,
    this.alamatLengkap = '',
    this.pathGambarTandaPengenal,
    this.status = StatusRegistrasi.awal,
    this.pesanError,
  });

  /// Semua field wajib harus terisi sebelum tombol Lanjut aktif.
  bool get isFormValid =>
      namaToko.isNotEmpty &&
      kategoriProduk.isNotEmpty &&
      jenisUsaha != null &&
      alamatLengkap.isNotEmpty;

  SellerRegistrationState copyWith({
    String? namaToko,
    String? kategoriProduk,
    String? jenisUsaha,
    String? alamatLengkap,
    String? pathGambarTandaPengenal,
    StatusRegistrasi? status,
    String? pesanError,
  }) =>
      SellerRegistrationState(
        namaToko: namaToko ?? this.namaToko,
        kategoriProduk: kategoriProduk ?? this.kategoriProduk,
        jenisUsaha: jenisUsaha ?? this.jenisUsaha,
        alamatLengkap: alamatLengkap ?? this.alamatLengkap,
        pathGambarTandaPengenal:
            pathGambarTandaPengenal ?? this.pathGambarTandaPengenal,
        status: status ?? this.status,
        pesanError: pesanError ?? this.pesanError,
      );
}
