import '../../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<OrderModel?> getOrderById(String id);
  Future<List<OrderModel>> getOrdersByUserId(String userId);
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId);
  Future<void> saveOrder(OrderModel order);
  Future<void> saveOrders(List<OrderModel> orders);
  Future<void> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
  Future<void> clearAll();
}
