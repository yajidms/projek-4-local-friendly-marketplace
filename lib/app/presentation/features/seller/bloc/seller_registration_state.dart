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

  // Sentinel untuk membedakan "tidak di-pass" vs "sengaja di-set ke null"
  static const Object _absent = Object();

  SellerRegistrationState copyWith({
    String? namaToko,
    String? kategoriProduk,
    Object? jenisUsaha = _absent, // Gunakan sentinel agar bisa reset ke null
    String? alamatLengkap,
    Object? pathGambarTandaPengenal = _absent,
    StatusRegistrasi? status,
    Object? pesanError = _absent,
  }) =>
      SellerRegistrationState(
        namaToko: namaToko ?? this.namaToko,
        kategoriProduk: kategoriProduk ?? this.kategoriProduk,
        jenisUsaha: jenisUsaha == _absent
            ? this.jenisUsaha
            : jenisUsaha as String?,
        alamatLengkap: alamatLengkap ?? this.alamatLengkap,
        pathGambarTandaPengenal: pathGambarTandaPengenal == _absent
            ? this.pathGambarTandaPengenal
            : pathGambarTandaPengenal as String?,
        status: status ?? this.status,
        pesanError: pesanError == _absent
            ? this.pesanError
            : pesanError as String?,
      );
}
