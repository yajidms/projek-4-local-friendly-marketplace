// File: lib/app/presentation/features/seller/bloc/seller_registration_event.dart

part of 'seller_registration_bloc.dart';

abstract class SellerRegistrationEvent {}

/// Dipanggil setiap kali field Nama Toko berubah.
class NamaTokoBerubah extends SellerRegistrationEvent {
  final String nilai;
  NamaTokoBerubah(this.nilai);
}

/// Dipanggil setiap kali field Kategori Produk berubah.
class KategoriProdukBerubah extends SellerRegistrationEvent {
  final String nilai;
  KategoriProdukBerubah(this.nilai);
}

/// Dipanggil saat user memilih Jenis Usaha dari dropdown.
class JenisUsahaBerubah extends SellerRegistrationEvent {
  final String? nilai;
  JenisUsahaBerubah(this.nilai);
}

/// Dipanggil setiap kali field Alamat berubah.
class AlamatBerubah extends SellerRegistrationEvent {
  final String nilai;
  AlamatBerubah(this.nilai);
}

/// Dipanggil saat user memilih foto tanda pengenal.
/// [path] adalah path file lokal dari image_picker.
class GambarTandaPengenalanDipilih extends SellerRegistrationEvent {
  final String path;
  GambarTandaPengenalanDipilih(this.path);
}

/// Dipanggil saat user menekan tombol "Lanjut".
class DaftarkanToko extends SellerRegistrationEvent {}
