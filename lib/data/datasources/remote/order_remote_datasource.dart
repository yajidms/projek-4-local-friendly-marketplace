import '../../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> getOrderById(String id);
  Future<List<OrderModel>> getOrdersByUserId(String userId);
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
}
