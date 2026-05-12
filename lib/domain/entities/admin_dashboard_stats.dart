/// A single data point for order trend charts.
class OrderTrend {
  final DateTime date;
  final int orderCount;
  final double revenue;

  OrderTrend({
    required this.date,
    required this.orderCount,
    required this.revenue,
  });
}

/// Aggregated statistics for the admin dashboard overview.
class AdminDashboardStats {
  final int totalUsers;
  final int totalSellers;
  final int totalProducts;
  final int totalOrders;
  final int pendingVerifications;
  final double totalRevenue;
  final List<OrderTrend> orderTrends;
  final Map<String, int> categoryDistribution;
  final int activeSellers;
  final int verifiedSellers;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalSellers,
    required this.totalProducts,
    required this.totalOrders,
    required this.pendingVerifications,
    required this.totalRevenue,
    required this.orderTrends,
    required this.categoryDistribution,
    required this.activeSellers,
    required this.verifiedSellers,
  });
}
