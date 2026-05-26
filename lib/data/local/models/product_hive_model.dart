// lib/data/local/models/product_hive_model.dart
//
// Model Hive untuk entitas Product.
// Menggunakan TypeAdapter manual (tanpa hive_generator) untuk menghindari
// konflik versi dengan build_runner.
//
// typeId: 0 — ID unik untuk adapter ini di Hive registry.
// JANGAN ubah typeId setelah app sudah di-deploy (data akan corrupt).

import 'package:hive/hive.dart';

import '../../../domain/entities/product.dart';

// ─── Konstanta field index ────────────────────────────────────────────────────
// Setiap field harus memiliki index unik yang konsisten.
// JANGAN mengubah urutan/value ini setelah ada data tersimpan.
const int _kId = 0;
const int _kSellerId = 1;
const int _kName = 2;
const int _kDescription = 3;
const int _kPrice = 4;
const int _kQuantity = 5;
const int _kCategory = 6;
const int _kImages = 7;
const int _kSku = 8;
const int _kWeight = 9;
const int _kUnit = 10;
const int _kIsAvailable = 11;
const int _kCreatedAt = 12;
const int _kUpdatedAt = 13;
const int _kLastSyncedAt = 14;
const int _kIsSynced = 15;
const int _kIsLocalOnly = 16;
const int _kSpecifications = 17; // ← field baru, index 17

/// TypeId yang digunakan di Hive registry — harus unik per app.
const int productHiveTypeId = 0;

/// Adapter manual Hive untuk [Product].
///
/// Mengkonversi [Product] domain entity ke format binary Hive (BinaryWriter)
/// dan sebaliknya (BinaryReader).
class ProductHiveAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = productHiveTypeId;

  @override
  Product read(BinaryReader reader) {
    // Baca jumlah field yang tersimpan
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Helper untuk membaca DateTime yang tersimpan sebagai int (ms epoch)
    DateTime readDate(int key, DateTime fallback) {
      final val = fields[key];
      if (val == null) return fallback;
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return fallback;
    }

    DateTime? readDateNullable(int key) {
      final val = fields[key];
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return Product(
      id: fields[_kId] as String? ?? '',
      sellerId: fields[_kSellerId] as String? ?? '',
      name: fields[_kName] as String? ?? '',
      description: fields[_kDescription] as String? ?? '',
      specifications: fields[_kSpecifications] as String?,
      price: (fields[_kPrice] as num?)?.toDouble() ?? 0.0,
      quantity: fields[_kQuantity] as int? ?? 0,
      category: fields[_kCategory] as String? ?? '',
      images: (fields[_kImages] as List?)?.cast<String>(),
      sku: fields[_kSku] as String?,
      weight: (fields[_kWeight] as num?)?.toDouble(),
      unit: fields[_kUnit] as String?,
      isAvailable: fields[_kIsAvailable] as bool? ?? true,
      createdAt: readDate(_kCreatedAt, DateTime.now()),
      updatedAt: readDate(_kUpdatedAt, DateTime.now()),
      lastSyncedAt: readDateNullable(_kLastSyncedAt),
      isSynced: fields[_kIsSynced] as bool? ?? false,
      isLocalOnly: fields[_kIsLocalOnly] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    // Hitung jumlah field yang akan ditulis
    // (selalu tulis semua field termasuk nullable agar konsisten)
    writer.writeByte(18); // total 18 field (index 0–17)

    writer.writeByte(_kId);
    writer.write(obj.id);

    writer.writeByte(_kSellerId);
    writer.write(obj.sellerId);

    writer.writeByte(_kName);
    writer.write(obj.name);

    writer.writeByte(_kDescription);
    writer.write(obj.description);

    writer.writeByte(_kSpecifications);
    writer.write(obj.specifications);

    writer.writeByte(_kPrice);
    writer.write(obj.price);

    writer.writeByte(_kQuantity);
    writer.write(obj.quantity);

    writer.writeByte(_kCategory);
    writer.write(obj.category);

    writer.writeByte(_kImages);
    writer.write(obj.images);

    writer.writeByte(_kSku);
    writer.write(obj.sku);

    writer.writeByte(_kWeight);
    writer.write(obj.weight);

    writer.writeByte(_kUnit);
    writer.write(obj.unit);

    writer.writeByte(_kIsAvailable);
    writer.write(obj.isAvailable);

    writer.writeByte(_kCreatedAt);
    writer.write(obj.createdAt.millisecondsSinceEpoch);

    writer.writeByte(_kUpdatedAt);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);

    writer.writeByte(_kLastSyncedAt);
    writer.write(obj.lastSyncedAt?.millisecondsSinceEpoch);

    writer.writeByte(_kIsSynced);
    writer.write(obj.isSynced);

    writer.writeByte(_kIsLocalOnly);
    writer.write(obj.isLocalOnly);
  }
}
