// lib/data/local/hive_init.dart
//
// Inisialisasi Hive: registrasi semua adapter dan buka box yang diperlukan.
// Panggil [initHive()] di main() SEBELUM runApp().

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/product.dart';
import 'models/product_hive_model.dart';

/// Inisialisasi Hive untuk seluruh aplikasi.
///
/// Urutan penting:
/// 1. [Hive.initFlutter()] — setup path penyimpanan di device
/// 2. Register semua TypeAdapter
/// 3. (Box dibuka oleh masing-masing repository saat factory .open() dipanggil)
Future<void> initHive() async {
  // 1. Inisialisasi path Hive sesuai platform (Android: app documents dir)
  await Hive.initFlutter();

  // 2. Register adapter Product
  //    Cek dulu agar tidak error jika adapter sudah terdaftar
  if (!Hive.isAdapterRegistered(productHiveTypeId)) {
    Hive.registerAdapter<Product>(ProductHiveAdapter());
  }
}
