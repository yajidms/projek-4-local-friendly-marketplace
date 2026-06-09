class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String storeName;
  final double storeLat;
  final double storeLng;
  double? distanceKm; // dihitung saat runtime

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.storeName,
    required this.storeLat,
    required this.storeLng,
    this.distanceKm,
  });

  // Simpan/baca dari Hive (pakai Map)
  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'price': price, 'stock': stock,
    'category': category, 'storeName': storeName,
    'storeLat': storeLat, 'storeLng': storeLng,
  };

  factory ProductModel.fromMap(Map map) => ProductModel(
    id: map['id'], name: map['name'], price: map['price'],
    stock: map['stock'], category: map['category'],
    storeName: map['storeName'], storeLat: map['storeLat'],
    storeLng: map['storeLng'],
  );
}