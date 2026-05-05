// File: lib/app/utils/image_compressor_util.dart
//
// NFR-03: Gambar produk HARUS dikompres ke ≤ 500 KB sebelum disimpan.
// OE-04:  Penggunaan storage lokal yang efisien untuk perangkat low-end.

import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Utility kompresi gambar sebelum menyimpan path ke local storage.
/// Digunakan oleh Seller BLoC sebelum menyimpan foto produk / tanda pengenal.
class ImageCompressorUtil {
  // NFR-03: Batas maksimum ukuran file gambar
  static const int _maxFileSizeKb = 500;
  static const int _maxDimension = 1024;
  static const int _initialQuality = 88;
  static const int _qualityStep = 10;
  static const int _minQuality = 20;

  /// Kompres [imagePath] lalu simpan hasilnya ke folder produk aplikasi.
  /// Mengembalikan path file hasil kompresi.
  ///
  /// Throws [Exception] jika kompresi gagal atau file masih > 500KB.
  static Future<String> compressAndSave(String imagePath) async {
    final srcFile = File(imagePath);
    if (!await srcFile.exists()) {
      throw Exception('File gambar tidak ditemukan: $imagePath');
    }

    // Jika sudah di bawah batas, cukup salin ke folder produk
    final srcSizeKb = (await srcFile.length()) / 1024;
    if (srcSizeKb <= _maxFileSizeKb) {
      return _copyToProductsDir(imagePath);
    }

    final appDir = await getApplicationDocumentsDirectory();
    final productsDir = Directory(p.join(appDir.path, 'pade_products'));
    await productsDir.create(recursive: true);

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imagePath)}';
    final targetPath = p.join(productsDir.path, fileName);

    // NFR-03: Turunkan kualitas secara bertahap sampai ≤ 500 KB
    int quality = _initialQuality;
    XFile? result;

    do {
      result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      quality -= _qualityStep;
    } while (result != null &&
        (await File(result.path).length()) / 1024 > _maxFileSizeKb &&
        quality >= _minQuality);

    if (result == null) {
      throw Exception('Gagal mengompres gambar produk');
    }

    final finalSizeKb = (await File(result.path).length()) / 1024;
    if (finalSizeKb > _maxFileSizeKb) {
      await File(result.path).delete().catchError((_) => File(result!.path));
      throw Exception(
          'Ukuran gambar melebihi batas maksimum ${_maxFileSizeKb}KB');
    }

    return result.path;
  }

  /// Salin file gambar kecil ke folder produk untuk konsistensi path.
  static Future<String> _copyToProductsDir(String imagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final productsDir = Directory(p.join(appDir.path, 'pade_products'));
    await productsDir.create(recursive: true);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imagePath)}';
    final dest = p.join(productsDir.path, fileName);
    await File(imagePath).copy(dest);
    return dest;
  }

  /// Kembalikan ukuran file dalam KB. Berguna untuk validasi di UI.
  static Future<double> getFileSizeKb(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return 0;
    return (await file.length()) / 1024;
  }
}
