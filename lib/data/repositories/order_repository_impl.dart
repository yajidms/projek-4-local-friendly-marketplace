import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderLocalDataSource localDataSource;
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Order>> getOrdersByUserId(String userId) async {
    try {
      final remoteOrders = await remoteDataSource.getOrdersByUserId(userId);
      await localDataSource.saveOrders(remoteOrders);
      return remoteOrders.map((o) => o.toEntity()).toList();
    } catch (e) {
      final cachedOrders = await localDataSource.getOrdersByUserId(userId);
      return cachedOrders.map((o) => o.toEntity()).toList();
    }
  }

  @override
  Future<List<Order>> getOrdersBySeller(String sellerId) async {
    try {
      final remoteOrders = await remoteDataSource.getOrdersBySellerId(sellerId);
      await localDataSource.saveOrders(remoteOrders);
      return remoteOrders.map((o) => o.toEntity()).toList();
    } catch (e) {
      final cachedOrders = await localDataSource.getOrdersBySellerId(sellerId);
      return cachedOrders.map((o) => o.toEntity()).toList();
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final remoteOrder = await remoteDataSource.getOrderById(orderId);
      await localDataSource.saveOrder(remoteOrder);
      return remoteOrder.toEntity();
    } catch (e) {
      final cachedOrder = await localDataSource.getOrderById(orderId);
      return cachedOrder?.toEntity();
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    final orderModel = OrderModel.fromEntity(order);
    await localDataSource.saveOrder(orderModel);
    try {
      final remoteOrder = await remoteDataSource.createOrder(orderModel);
      await localDataSource.saveOrder(remoteOrder);
      return remoteOrder.toEntity();
    } catch (e) {
      return orderModel.toEntity();
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    final remoteOrder = await remoteDataSource.updateOrderStatus(orderId, status.value);
    await localDataSource.saveOrder(remoteOrder);
    return remoteOrder.toEntity();
  }

  @override
  Future<List<Order>> getOrdersByStatus(String sellerId, OrderStatus status) async {
    try {
      final remoteOrders = await remoteDataSource.getOrdersBySellerId(sellerId);
      await localDataSource.saveOrders(remoteOrders);
      return remoteOrders
          .where((o) => o.status == status.value)
          .map((o) => o.toEntity())
          .toList();
    } catch (e) {
      final cachedOrders = await localDataSource.getOrdersBySellerId(sellerId);
      return cachedOrders
          .where((o) => o.status == status.value)
          .map((o) => o.toEntity())
          .toList();
    }
  }
}
