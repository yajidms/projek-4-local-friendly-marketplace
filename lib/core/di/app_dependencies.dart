import '../../data/datasources/local/hive_order_local_datasource.dart';
import '../../data/datasources/local/hive_user_local_datasource.dart';
import '../../data/datasources/local/in_memory_local_datasources.dart';
import '../../data/datasources/local/order_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/local/seller_local_datasource.dart';
import '../../data/datasources/local/user_local_datasource.dart';
import '../../data/datasources/remote/http_order_remote_datasource.dart';
import '../../data/datasources/remote/http_product_remote_datasource.dart';
import '../../data/datasources/remote/http_seller_remote_datasource.dart';
import '../../data/datasources/remote/http_user_remote_datasource.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';
import '../../data/datasources/remote/seller_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/seller_repository.dart';
import '../../domain/repositories/user_repository.dart';

class AppDependencies {
  AppDependencies._();

  static final ProductLocalDataSource productLocal = InMemoryProductLocalDataSource();
  static final ProductRemoteDataSource productRemote = HttpProductRemoteDataSource();
  static final ProductRepository productRepository = ProductRepositoryImpl(
    localDataSource: productLocal,
    remoteDataSource: productRemote,
  );

  static final SellerLocalDataSource sellerLocal = InMemorySellerLocalDataSource();
  static final SellerRemoteDataSource sellerRemote = HttpSellerRemoteDataSource();
  static final SellerRepository sellerRepository = SellerRepositoryImpl(
    localDataSource: sellerLocal,
    remoteDataSource: sellerRemote,
  );

  static final UserLocalDataSource userLocal = HiveUserLocalDataSource();
  static final UserRemoteDataSource userRemote = HttpUserRemoteDataSource();
  static final UserRepository userRepository = UserRepositoryImpl(
    localDataSource: userLocal,
    remoteDataSource: userRemote,
  );

  static final OrderLocalDataSource orderLocal = HiveOrderLocalDataSource();
  static final OrderRemoteDataSource orderRemote = HttpOrderRemoteDataSource();
  static final OrderRepository orderRepository = OrderRepositoryImpl(
    localDataSource: orderLocal,
    remoteDataSource: orderRemote,
  );
}
