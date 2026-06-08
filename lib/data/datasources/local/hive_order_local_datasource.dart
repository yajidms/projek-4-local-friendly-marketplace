import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/order_model.dart';
import 'order_local_datasource.dart';

class HiveOrderLocalDataSource implements OrderLocalDataSource {
  static const _boxName = 'orders';

  Future<Box<String>> get _box => Hive.openBox<String>(_boxName);

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return null;
    return OrderModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final box = await _box;
    final all = box.values.map((json) => OrderModel.fromJson(jsonDecode(json) as Map<String, dynamic>));
    return all.where((o) => o.userId == userId).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId) async {
    final box = await _box;
    final all = box.values.map((json) => OrderModel.fromJson(jsonDecode(json) as Map<String, dynamic>));
    return all.where((o) => o.sellerId == sellerId).toList();
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    final box = await _box;
    await box.put(order.id, jsonEncode(order.toJson()));
  }

  @override
  Future<void> saveOrders(List<OrderModel> orders) async {
    final box = await _box;
    for (final order in orders) {
      await box.put(order.id, jsonEncode(order.toJson()));
    }
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    final box = await _box;
    await box.put(order.id, jsonEncode(order.toJson()));
  }

  @override
  Future<void> deleteOrder(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}
