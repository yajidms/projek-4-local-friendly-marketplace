import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/local/admin_mock_datasource.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../routes/admin_router.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/stat_card.dart';

/// Admin dashboard overview page with stats cards and charts.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AdminDashboardStats _stats;

  @override
  void initState() {
    super.initState();
    _stats = AdminMockDatasource().getDashboardStats();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.dashboard,
      title: 'Dashboard',
      subtitle: 'Selamat datang di PaDe Admin Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Stat Cards ───────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 1000
                  ? 5
                  : constraints.maxWidth > 700
                      ? 3
                      : 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    Icons.people_rounded,
                    'Total Pengguna',
                    '${_stats.totalUsers}',
                    '+12%',
                    true,
                    AdminTheme.info,
                    constraints.maxWidth,
                    crossCount,
                  ),
                  _buildStatCard(
                    Icons.storefront_rounded,
                    'Total Toko',
                    '${_stats.totalSellers}',
                    '+8%',
                    true,
                    AdminTheme.primaryLight,
                    constraints.maxWidth,
                    crossCount,
                  ),
                  _buildStatCard(
                    Icons.hourglass_top_rounded,
                    'Pending Verifikasi',
                    '${_stats.pendingVerifications}',
                    null,
                    null,
                    AdminTheme.warning,
                    constraints.maxWidth,
                    crossCount,
                  ),
                  _buildStatCard(
                    Icons.receipt_long_rounded,
                    'Total Pesanan',
                    '${_stats.totalOrders}',
                    '+18%',
                    true,
                    AdminTheme.accent,
                    constraints.maxWidth,
                    crossCount,
                  ),
                  _buildStatCard(
                    Icons.payments_rounded,
                    'Total Pendapatan',
                    _formatCurrency(_stats.totalRevenue),
                    '+24%',
                    true,
                    AdminTheme.success,
                    constraints.maxWidth,
                    crossCount,
                  ),
                ],
              );
            }),

            const SizedBox(height: 28),

            // ─── Charts Row ──────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildOrderTrendChart()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildCategoryChart()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildOrderTrendChart(),
                  const SizedBox(height: 16),
                  _buildCategoryChart(),
                ],
              );
            }),

            const SizedBox(height: 28),

            // ─── Quick Actions ───────────────────────────
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String? trend,
    bool? trendUp,
    Color color,
    double parentWidth,
    int crossCount,
  ) {
    final spacing = 16.0 * (crossCount - 1);
    final cardWidth = (parentWidth - spacing) / crossCount;
    return SizedBox(
      width: cardWidth.clamp(150, 400),
      child: StatCard(
        icon: icon,
        label: label,
        value: value,
        trend: trend,
        trendUp: trendUp,
        color: color,
      ),
    );
  }

  Widget _buildOrderTrendChart() {
    final trends = _stats.orderTrends;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Pesanan (30 Hari)',
            style: TextStyle(
              color: AdminTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AdminTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                            color: AdminTheme.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < trends.length) {
                          final d = trends[idx].date;
                          return Text(
                            '${d.day}/${d.month}',
                            style: const TextStyle(
                                color: AdminTheme.textMuted, fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      trends.length,
                      (i) => FlSpot(
                          i.toDouble(), trends[i].orderCount.toDouble()),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AdminTheme.primaryLight,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AdminTheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categories = _stats.categoryDistribution;
    final colors = [
      AdminTheme.primary,
      AdminTheme.info,
      AdminTheme.warning,
      AdminTheme.danger,
      AdminTheme.accent,
      AdminTheme.primaryLight,
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Kategori',
            style: TextStyle(
              color: AdminTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: categories.entries.toList().asMap().entries.map((e) {
                  final idx = e.key;
                  final entry = e.value;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: colors[idx % colors.length],
                    radius: 28,
                    showTitle: false,
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.entries.toList().asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                          color: AdminTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              color: AdminTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _quickActionButton(
                Icons.verified_user_rounded,
                'Review Verifikasi (${_stats.pendingVerifications})',
                AdminTheme.warning,
                () => Navigator.of(context)
                    .pushReplacementNamed(AdminRoutes.verification),
              ),
              _quickActionButton(
                Icons.people_rounded,
                'Lihat Pengguna',
                AdminTheme.info,
                () => Navigator.of(context)
                    .pushReplacementNamed(AdminRoutes.users),
              ),
              _quickActionButton(
                Icons.receipt_long_rounded,
                'Kelola Pesanan',
                AdminTheme.primaryLight,
                () => Navigator.of(context)
                    .pushReplacementNamed(AdminRoutes.orders),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
