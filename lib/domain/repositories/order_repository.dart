// File: lib/domain/repositories/order_repository.dart
//
// Abstract interface untuk operasi Order dari sisi penjual.
// Implementasi konkret ada di data layer (atau MockOrderRepository saat testing).

import '../entities/index.dart';

abstract class OrderRepository {
  /// Ambil semua pesanan milik pembeli [userId].
  Future<List<Order>> getOrdersByUserId(String userId);

  /// Ambil semua pesanan yang ditujukan ke penjual [sellerId].
  Future<List<Order>> getOrdersBySeller(String sellerId);

  /// Ambil semua pesanan milik pembeli (user yang login).
  Future<List<Order>> getOrdersByBuyer(String userId);

  /// Ambil detail pesanan berdasarkan [orderId].
  Future<Order?> getOrderById(String orderId);

  /// Buat pesanan baru.
  Future<Order> createOrder(Order order);

  /// Perbarui status pesanan.
  Future<Order> updateOrderStatus(String orderId, OrderStatus status);

  /// Ambil pesanan berdasarkan status.
  Future<List<Order>> getOrdersByStatus(String sellerId, OrderStatus status);
}
