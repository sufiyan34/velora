import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/controllers/admin_dashboard_controller.dart';
import 'package:e_commerce/models/order_model.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_card.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/order_status_style.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminDashboardController>()
        ? Get.find<AdminDashboardController>()
        : Get.put(AdminDashboardController(), permanent: true);

    final bool mobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Obx(() {
          // Reading these here registers the whole page with every stream it
          // renders from — child widgets build outside this closure, so their
          // own reads wouldn't be tracked.
          final snapshot = (
            orders: controller.orders.length,
            users: controller.users.length,
            products: controller.products.length,
            range: controller.range.value,
          );

          if (controller.isLoading && snapshot.orders == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(mobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(controller: controller),
                const SizedBox(height: 16),
                const _QuickActions(),
                const SizedBox(height: 20),
                _StatGrid(controller: controller),
                const SizedBox(height: 18),
                _ChartsRow(controller: controller, mobile: mobile),
                const SizedBox(height: 18),
                _BottomRow(controller: controller, mobile: mobile),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ===========================================================================
// HEADER + RANGE SWITCH
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dashboard', style: AdminText.display(26)),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                '${controller.range.value.label.toLowerCase()} · '
                '${controller.totalOrders} orders placed',
                style: AdminText.body(13.5, color: AdminColors.muted),
              ),
            ),
          ],
        ),
        Obx(
          () => _RangeSwitch(
            value: controller.range.value,
            onChanged: controller.setRange,
          ),
        ),
      ],
    );
  }
}

class _RangeSwitch extends StatelessWidget {
  const _RangeSwitch({required this.value, required this.onChanged});

  final DashboardRange value;
  final ValueChanged<DashboardRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: DashboardRange.values.map((range) {
          final bool active = range == value;
          return GestureDetector(
            onTap: () => onChanged(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AdminColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                range.shortLabel,
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: active ? Colors.white : AdminColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        AdminQuickAction(
          label: 'Add product',
          icon: Icons.add_rounded,
          onTap: () => Get.toNamed(AppRoutes.adminProducts),
        ),
        AdminQuickAction(
          label: 'Review orders',
          icon: Icons.receipt_long_rounded,
          onTap: () => Get.toNamed(AppRoutes.adminOrders),
        ),
        AdminQuickAction(
          label: 'Manage categories',
          icon: Icons.category_outlined,
          onTap: () => Get.toNamed(AppRoutes.adminCategories),
        ),
        AdminQuickAction(
          label: 'Dispatch queue',
          icon: Icons.local_shipping_outlined,
          onTap: () => Get.toNamed(AppRoutes.dispatchedOrders),
        ),
      ],
    );
  }
}

// ===========================================================================
// KPI GRID
// ===========================================================================

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns = width >= 1180
            ? 4
            : width >= 860
            ? 3
            : width >= 560
            ? 2
            : 1;
        const spacing = 14.0;
        final cardWidth = (width - (spacing * (columns - 1))) / columns;

        final currency = controller.currency;

        final cards = <Widget>[
          AdminStatCard(
            label: 'Total sales',
            value: AdminFormat.moneyShort(
              controller.totalSales,
              currency: currency,
            ),
            icon: Icons.payments_outlined,
            delta: controller.salesDelta,
            accent: AdminColors.brass,
            tint: AdminColors.brassTint,
          ),
          AdminStatCard(
            label: 'Orders',
            value: AdminFormat.number(controller.totalOrders),
            icon: Icons.receipt_long_outlined,
            delta: controller.ordersDelta,
            accent: const Color(0xFF4B5E7A),
            tint: const Color(0xFFEAEFF6),
            onTap: () => Get.toNamed(AppRoutes.adminOrders),
          ),
          AdminStatCard(
            label: 'Customers',
            value: AdminFormat.number(controller.totalCustomers),
            icon: Icons.people_alt_outlined,
            footnote: '${controller.newCustomersInRange} new this period',
            accent: AdminColors.success,
            tint: AdminColors.successTint,
            onTap: () => Get.toNamed(AppRoutes.adminCustomers),
          ),
          AdminStatCard(
            label: 'Average order value',
            value: AdminFormat.moneyShort(
              controller.averageOrderValue,
              currency: currency,
            ),
            icon: Icons.insights_outlined,
            footnote: '${controller.deliveredInRange} delivered this period',
            accent: const Color(0xFF6B5A80),
            tint: const Color(0xFFF0ECF5),
          ),
          AdminStatCard(
            label: 'Pending orders',
            value: AdminFormat.number(controller.pendingOrders),
            icon: Icons.schedule_rounded,
            footnote: controller.pendingOrders == 0
                ? 'Nothing waiting on you'
                : 'Waiting for accept or reject',
            accent: AdminColors.warn,
            tint: AdminColors.warnTint,
            onTap: () => Get.toNamed(AppRoutes.adminOrders),
          ),
          AdminStatCard(
            label: 'Awaiting dispatch',
            value: AdminFormat.number(controller.awaitingDispatch),
            icon: Icons.local_shipping_outlined,
            footnote: 'Accepted or being packed',
            accent: AdminColors.brassDark,
            tint: AdminColors.brassTint,
            onTap: () => Get.toNamed(AppRoutes.dispatchedOrders),
          ),
          AdminStatCard(
            label: 'Products',
            value: AdminFormat.number(controller.totalProducts),
            icon: Icons.inventory_2_outlined,
            footnote: '${controller.lowStockProducts.length} need restocking',
            accent: const Color(0xFF3E6B57),
            tint: const Color(0xFFE8F1EC),
            onTap: () => Get.toNamed(AppRoutes.adminProducts),
          ),
          AdminStatCard(
            label: 'Out of stock',
            value: AdminFormat.number(controller.outOfStockCount),
            icon: Icons.report_gmailerrorred_outlined,
            footnote: controller.outOfStockCount == 0
                ? 'Every product is sellable'
                : 'Hidden from customers until restocked',
            accent: AdminColors.danger,
            tint: AdminColors.dangerTint,
            onTap: () => Get.toNamed(AppRoutes.inventory),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (int i = 0; i < cards.length; i++)
              SizedBox(
                width: cardWidth,
                child: cards[i]
                    .animate(delay: Duration(milliseconds: 40 * i))
                    .fadeIn(duration: const Duration(milliseconds: 320))
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic),
              ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// SALES CHART + CATEGORY SPLIT
// ===========================================================================

class _ChartsRow extends StatelessWidget {
  const _ChartsRow({required this.controller, required this.mobile});

  final AdminDashboardController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final sales = _SalesCard(controller: controller);
    final categories = _CategoryCard(controller: controller);

    if (mobile) {
      return Column(children: [sales, const SizedBox(height: 18), categories]);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: sales),
          const SizedBox(width: 18),
          Expanded(flex: 3, child: categories),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final points = controller.salesSeries;
    final currency = controller.currency;
    final double maxY = points.fold<double>(
      0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    return AdminSectionCard(
      title: 'Sales overview',
      subtitle: controller.range.value.label,
      trailing: Text(
        AdminFormat.moneyShort(controller.totalSales, currency: currency),
        style: AdminText.display(18, color: AdminColors.brassDark),
      ),
      child: SizedBox(
        height: 250,
        child: maxY <= 0
            ? const AdminEmptyHint(
                message: 'No sales recorded in this period yet.',
                icon: Icons.show_chart_rounded,
                height: 250,
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8, right: 6),
                child: LineChart(
                  _lineData(points, maxY, currency),
                  duration: const Duration(milliseconds: 420),
                ),
              ),
      ),
    );
  }

  LineChartData _lineData(
    List<SalesPoint> points,
    double maxY,
    String currency,
  ) {
    final double headroom = maxY * 1.18;
    final double interval = headroom / 4 <= 0 ? 1 : headroom / 4;

    // Only every nth x label is drawn, otherwise 30 days of labels collide.
    final int labelStep = (points.length / 6).ceil().clamp(1, 12);

    return LineChartData(
      minY: 0,
      maxY: headroom,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AdminColors.line, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            interval: interval,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                AdminFormat.compact(value),
                textAlign: TextAlign.right,
                style: AdminText.body(10.5, color: AdminColors.muted),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index < 0 || index >= points.length) {
                return const SizedBox.shrink();
              }
              if (index % labelStep != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  points[index].label,
                  style: AdminText.body(10.5, color: AdminColors.muted),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AdminColors.ink,
          getTooltipItems: (spots) => spots.map((spot) {
            final point = points[spot.spotIndex];
            return LineTooltipItem(
              '${point.label}\n'
              '${AdminFormat.money(point.revenue, currency: currency)} · '
              '${point.orderCount} orders',
              AdminText.body(11.5, color: Colors.white),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < points.length; i++)
              FlSpot(i.toDouble(), points[i].revenue),
          ],
          isCurved: true,
          curveSmoothness: 0.28,
          preventCurveOverShooting: true,
          color: AdminColors.brass,
          barWidth: 2.6,
          dotData: FlDotData(
            show: points.length <= 10,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3.4,
              color: AdminColors.surface,
              strokeWidth: 2,
              strokeColor: AdminColors.brass,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AdminColors.brass.withValues(alpha: 0.24),
                AdminColors.brass.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.controller});

  final AdminDashboardController controller;

  static const _palette = <Color>[
    Color(0xFFA6813C),
    Color(0xFF4E4468),
    Color(0xFF3E6B57),
    Color(0xFF7A4B57),
    Color(0xFF4B5E7A),
    Color(0xFFB0A89B),
  ];

  @override
  Widget build(BuildContext context) {
    final shares = controller.topCategories();
    final currency = controller.currency;

    return AdminSectionCard(
      title: 'Top categories',
      subtitle: 'Revenue share',
      child: shares.isEmpty
          ? const AdminEmptyHint(
              message: 'Category split appears once orders come in.',
              icon: Icons.donut_large_rounded,
              height: 250,
            )
          : Column(
              children: [
                SizedBox(
                  height: 168,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 48,
                      startDegreeOffset: -90,
                      sections: [
                        for (int i = 0; i < shares.length; i++)
                          PieChartSectionData(
                            value: shares[i].revenue,
                            color: _palette[i % _palette.length],
                            radius: 26,
                            showTitle: false,
                          ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 420),
                  ),
                ),
                const SizedBox(height: 14),
                for (int i = 0; i < shares.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _palette[i % _palette.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            shares[i].name,
                            overflow: TextOverflow.ellipsis,
                            style: AdminText.body(12.5),
                          ),
                        ),
                        Text(
                          '${(shares[i].share * 100).toStringAsFixed(0)}%',
                          style: AdminText.body(
                            12.5,
                            weight: FontWeight.w600,
                            color: AdminColors.inkSoft,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AdminFormat.moneyShort(
                            shares[i].revenue,
                            currency: currency,
                          ),
                          style: AdminText.body(12, color: AdminColors.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ===========================================================================
// RECENT ORDERS + STOCK ALERTS
// ===========================================================================

class _BottomRow extends StatelessWidget {
  const _BottomRow({required this.controller, required this.mobile});

  final AdminDashboardController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final recent = _RecentOrdersCard(controller: controller);
    final stock = _StockAlertsCard(controller: controller);

    if (mobile) {
      return Column(children: [recent, const SizedBox(height: 18), stock]);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: recent),
          const SizedBox(width: 18),
          Expanded(flex: 3, child: stock),
        ],
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.recentOrders();

    return AdminSectionCard(
      title: 'Recent orders',
      subtitle: 'Newest first',
      trailing: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.adminOrders),
        style: TextButton.styleFrom(foregroundColor: AdminColors.brassDark),
        child: Text(
          'View all',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.brassDark,
          ),
        ),
      ),
      child: orders.isEmpty
          ? const AdminEmptyHint(message: 'No orders yet.')
          : Column(
              children: [
                for (final order in orders)
                  _OrderRow(order: order, controller: controller),
              ],
            ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.controller});

  final OrderModel order;
  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () =>
          Get.toNamed(AppRoutes.orderDetails, arguments: {'orderId': order.id}),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            AdminSwatch(seed: controller.customerNameFor(order), size: 34),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.customerNameFor(order),
                    overflow: TextOverflow.ellipsis,
                    style: AdminText.body(13.5, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AdminFormat.orderRef(order.id)} · '
                    '${order.itemCount} items · '
                    '${AdminFormat.relative(order.createdAt)}',
                    overflow: TextOverflow.ellipsis,
                    style: AdminText.body(11.5, color: AdminColors.muted),
                  ),
                ],
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OrderStatusStyle.badge(order.orderStatus),
                ),
              ),
            ],
            const SizedBox(width: 10),
            Text(
              AdminFormat.money(order.total, currency: order.currency),
              style: AdminText.body(13, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockAlertsCard extends StatelessWidget {
  const _StockAlertsCard({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> lowStock = controller.lowStockProducts
        .take(6)
        .toList();

    return AdminSectionCard(
      title: 'Needs restocking',
      subtitle: 'Low and out of stock',
      trailing: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.inventory),
        style: TextButton.styleFrom(foregroundColor: AdminColors.brassDark),
        child: Text(
          'Inventory',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.brassDark,
          ),
        ),
      ),
      child: lowStock.isEmpty
          ? const AdminEmptyHint(
              message: 'Every product is comfortably in stock.',
              icon: Icons.check_circle_outline_rounded,
            )
          : Column(
              children: [
                for (final product in lowStock)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        AdminSwatch(seed: product.name, size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                overflow: TextOverflow.ellipsis,
                                style: AdminText.body(
                                  13,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.sku,
                                overflow: TextOverflow.ellipsis,
                                style: AdminText.body(
                                  11.5,
                                  color: AdminColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AdminBadge.stock(stock: product.stock),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
