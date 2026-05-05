// File: lib/app/presentation/features/seller/bloc/seller_registration_bloc.dart
//
// Mengelola alur form Registrasi Toko.
// Menggunakan SellerRepository (abstract interface) — tidak bergantung pada
// implementasi konkret (sesuai Clean Architecture).

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/index.dart';
import '../../../../../domain/repositories/seller_repository.dart';
import '../../../../utils/image_compressor_util.dart';

part 'seller_registration_event.dart';
part 'seller_registration_state.dart';

class SellerRegistrationBloc
    extends Bloc<SellerRegistrationEvent, SellerRegistrationState> {
  final SellerRepository sellerRepository;

  SellerRegistrationBloc({required this.sellerRepository})
      : super(const SellerRegistrationState()) {
    on<NamaTokoBerubah>(_onNamaToko);
    on<KategoriProdukBerubah>(_onKategori);
    on<JenisUsahaBerubah>(_onJenisUsaha);
    on<AlamatBerubah>(_onAlamat);
    on<GambarTandaPengenalanDipilih>(_onGambar);
    on<DaftarkanToko>(_onDaftar);
  }

  void _onNamaToko(NamaTokoBerubah e, Emitter<SellerRegistrationState> emit) =>
      emit(state.copyWith(namaToko: e.nilai));

  void _onKategori(
          KategoriProdukBerubah e, Emitter<SellerRegistrationState> emit) =>
      emit(state.copyWith(kategoriProduk: e.nilai));

  void _onJenisUsaha(
          JenisUsahaBerubah e, Emitter<SellerRegistrationState> emit) =>
      emit(state.copyWith(jenisUsaha: e.nilai));

  void _onAlamat(AlamatBerubah e, Emitter<SellerRegistrationState> emit) =>
      emit(state.copyWith(alamatLengkap: e.nilai));

  /// NFR-03: Kompres foto tanda pengenal ke < 500 KB sebelum menyimpan path.
  Future<void> _onGambar(
    GambarTandaPengenalanDipilih event,
    Emitter<SellerRegistrationState> emit,
  ) async {
    try {
      final compressed = await ImageCompressorUtil.compressAndSave(event.path);
      emit(state.copyWith(pathGambarTandaPengenal: compressed));
    } catch (_) {
      // Jika kompresi gagal, tetap simpan path asli (soft failure)
      emit(state.copyWith(pathGambarTandaPengenal: event.path));
    }
  }

  /// Submit: buat objek Seller dari form, lalu simpan via SellerRepository.
  Future<void> _onDaftar(
    DaftarkanToko event,
    Emitter<SellerRegistrationState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: StatusRegistrasi.gagal,
        pesanError: 'Harap lengkapi semua kolom yang diperlukan.',
      ));
      return;
    }

    emit(state.copyWith(status: StatusRegistrasi.memuat));

    try {
      final now = DateTime.now();
      final seller = Seller(
        id: '', // Diisi oleh server / UUID lokal saat implementasi penuh
        userId: '', // Diisi dari sesi autentikasi yang aktif
        shopName: state.namaToko,
        shopDescription: state.jenisUsaha,
        shopAddress: state.alamatLengkap,
        shopImageUrl: state.pathGambarTandaPengenal,
        categories: state.kategoriProduk
            .split(',')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList(),
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );
      await sellerRepository.createSeller(seller);
      emit(state.copyWith(status: StatusRegistrasi.berhasil));
    } catch (e) {
      emit(state.copyWith(
        status: StatusRegistrasi.gagal,
        pesanError: 'Pendaftaran gagal: ${e.toString()}',
      ));
    }
  }
}
