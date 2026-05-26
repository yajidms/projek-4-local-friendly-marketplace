// File: lib/domain/repositories/order_repository.dart
//
// Abstract interface untuk operasi Order dari sisi penjual.
// Implementasi konkret ada di data layer (atau MockOrderRepository saat testing).

import '../entities/index.dart';

abstract class OrderRepository {
  /// Ambil semua pesanan yang ditujukan ke penjual [sellerId].
  Future<List<Order>> getOrdersBySeller(String sellerId);

  /// Ambil detail pesanan berdasarkan [orderId].
  Future<Order?> getOrderById(String orderId);

  /// Perbarui status pesanan.
  Future<Order> updateOrderStatus(String orderId, OrderStatus status);

  /// Ambil pesanan berdasarkan status.
  Future<List<Order>> getOrdersByStatus(String sellerId, OrderStatus status);
}
