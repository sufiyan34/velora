import 'dart:async';

import 'package:e_commerce/repositories/admin_repositery.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../utills/order_status_style.dart';
import 'product_controller.dart';

/// Time window the dashboard reports on.
enum DashboardRange { days7, days30, months12 }

extension DashboardRangeX on DashboardRange {
  String get label => switch (this) {
    DashboardRange.days7 => 'Last 7 days',
    DashboardRange.days30 => 'Last 30 days',
    DashboardRange.months12 => 'Last 12 months',
  };

  String get shortLabel => switch (this) {
    DashboardRange.days7 => '7D',
    DashboardRange.days30 => '30D',
    DashboardRange.months12 => '12M',
  };

  /// Length of one window, used for the previous-period comparison.
  Duration get span => switch (this) {
    DashboardRange.days7 => const Duration(days: 7),
    DashboardRange.days30 => const Duration(days: 30),
    DashboardRange.months12 => const Duration(days: 365),
  };
}

/// One point on the sales chart.
class SalesPoint {
  const SalesPoint({
    required this.label,
    required this.revenue,
    required this.orderCount,
  });

  final String label;
  final double revenue;
  final int orderCount;
}

/// One slice of the category breakdown.
class CategoryShare {
  const CategoryShare({
    required this.name,
    required this.revenue,
    required this.share,
  });

  final String name;
  final double revenue;

  /// 0.0 – 1.0
  final double share;
}

class AdminDashboardController extends GetxController {
  AdminDashboardController({AdminRepository? repository})
    : _repo = repository ?? AdminRepository();

  final AdminRepository _repo;

  // ============================================================
  // STATE
  // ============================================================

  final orders = <OrderModel>[].obs;
  final users = <UserModel>[].obs;

  final isLoadingOrders = true.obs;
  final isLoadingUsers = true.obs;
  final errorMessage = ''.obs;

  final range = DashboardRange.days30.obs;

  StreamSubscription<List<OrderModel>>? _ordersSub;
  StreamSubscription<List<UserModel>>? _usersSub;

  late final ProductController _products;

  bool get isLoading => isLoadingOrders.value || isLoadingUsers.value;

  List<ProductModel> get products => _products.products;

  /// Currency of the store, taken from live data with a safe fallback.
  String get currency => orders.isEmpty ? 'USD' : orders.first.currency;

  @override
  void onInit() {
    super.onInit();

    // Products already have a controller with a live stream — reuse it so we
    // don't open a second listener on the same node.
    _products = Get.isRegistered<ProductController>(tag: 'products')
        ? Get.find<ProductController>(tag: 'products')
        : Get.put(ProductController(), tag: 'products', permanent: true);

    _ordersSub = _repo.watchAllOrders().listen(
      (list) {
        orders.assignAll(list);
        isLoadingOrders.value = false;
      },
      onError: (Object error) {
        isLoadingOrders.value = false;
        errorMessage.value = error.toString();
      },
    );

    _usersSub = _repo.watchAllUsers().listen(
      (list) {
        users.assignAll(list);
        isLoadingUsers.value = false;
      },
      onError: (Object error) {
        isLoadingUsers.value = false;
        errorMessage.value = error.toString();
      },
    );
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _usersSub?.cancel();
    super.onClose();
  }

  void setRange(DashboardRange value) => range.value = value;

  // ============================================================
  // WINDOWING
  // ============================================================

  DateTime get _windowStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (range.value) {
      DashboardRange.days7 => today.subtract(const Duration(days: 6)),
      DashboardRange.days30 => today.subtract(const Duration(days: 29)),
      DashboardRange.months12 => DateTime(now.year, now.month - 11, 1),
    };
  }

  bool _isEarning(OrderModel order) =>
      OrderStatuses.earning.contains(order.orderStatus);

  List<OrderModel> _within(DateTime start, DateTime end) {
    return orders.where((order) {
      final created = order.createdAt;
      if (created == null) return false;
      return !created.isBefore(start) && created.isBefore(end);
    }).toList();
  }

  /// Orders placed inside the selected window.
  List<OrderModel> get ordersInRange =>
      _within(_windowStart, DateTime.now().add(const Duration(days: 1)));

  List<OrderModel> get _ordersInPreviousRange {
    final start = _windowStart;
    return _within(start.subtract(range.value.span), start);
  }

  // ============================================================
  // HEADLINE NUMBERS
  // ============================================================

  double get totalSales => ordersInRange
      .where(_isEarning)
      .fold<double>(0, (sum, order) => sum + order.total);

  double get _previousSales => _ordersInPreviousRange
      .where(_isEarning)
      .fold<double>(0, (sum, order) => sum + order.total);

  int get totalOrders => ordersInRange.length;

  int get _previousOrderCount => _ordersInPreviousRange.length;

  int get pendingOrders =>
      orders.where((o) => o.orderStatus == OrderStatuses.pending).length;

  int get awaitingDispatch => orders
      .where(
        (o) =>
            o.orderStatus == OrderStatuses.accepted ||
            o.orderStatus == OrderStatuses.processing,
      )
      .length;

  int get deliveredInRange => ordersInRange
      .where((o) => o.orderStatus == OrderStatuses.delivered)
      .length;

  double get averageOrderValue {
    final earning = ordersInRange.where(_isEarning).toList();
    if (earning.isEmpty) return 0;
    return totalSales / earning.length;
  }

  List<UserModel> get customers => users.where((u) => u.isCustomer).toList();

  int get totalCustomers => customers.length;

  int get newCustomersInRange {
    final start = _windowStart;
    return customers.where((u) {
      final created = u.createdAt;
      return created != null && !created.isBefore(start);
    }).length;
  }

  int get totalProducts => products.length;

  List<ProductModel> get lowStockProducts {
    final list = products.where((p) => p.isLowStock || p.isOutOfStock).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    return list;
  }

  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  /// Percentage change against the previous window. `null` when there is no
  /// previous data to compare against, so the UI can show a dash.
  double? get salesDelta => _delta(totalSales, _previousSales);

  double? get ordersDelta =>
      _delta(totalOrders.toDouble(), _previousOrderCount.toDouble());

  double? _delta(double current, double previous) {
    if (previous <= 0) return current > 0 ? 100 : null;
    return ((current - previous) / previous) * 100;
  }

  // ============================================================
  // SALES SERIES
  // ============================================================

  List<SalesPoint> get salesSeries {
    final now = DateTime.now();
    final earning = ordersInRange.where(_isEarning).toList();

    if (range.value == DashboardRange.months12) {
      final points = <SalesPoint>[];
      for (int i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final next = DateTime(month.year, month.month + 1, 1);
        final bucket = earning.where((o) {
          final d = o.createdAt!;
          return !d.isBefore(month) && d.isBefore(next);
        });
        points.add(
          SalesPoint(
            label: DateFormat('MMM').format(month),
            revenue: bucket.fold<double>(0, (s, o) => s + o.total),
            orderCount: bucket.length,
          ),
        );
      }
      return points;
    }

    final days = range.value == DashboardRange.days7 ? 7 : 30;
    final today = DateTime(now.year, now.month, now.day);
    final points = <SalesPoint>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final bucket = earning.where((o) {
        final d = o.createdAt!;
        return !d.isBefore(day) && d.isBefore(next);
      });
      points.add(
        SalesPoint(
          label: DateFormat('MMM d').format(day),
          revenue: bucket.fold<double>(0, (s, o) => s + o.total),
          orderCount: bucket.length,
        ),
      );
    }
    return points;
  }

  // ============================================================
  // BREAKDOWNS
  // ============================================================

  /// Revenue share per category, biggest first, capped at [limit] slices with
  /// the remainder folded into "Other".
  List<CategoryShare> topCategories({int limit = 5}) {
    final byCategory = <String, double>{};

    for (final order in ordersInRange.where(_isEarning)) {
      for (final item in order.items) {
        final product = _productById(item.productId);
        final name = (product?.categoryName.trim().isNotEmpty ?? false)
            ? product!.categoryName
            : 'Uncategorised';
        byCategory[name] = (byCategory[name] ?? 0) + item.total;
      }
    }

    final total = byCategory.values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) return const [];

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final shares = <CategoryShare>[];
    for (final entry in entries.take(limit)) {
      shares.add(
        CategoryShare(
          name: entry.key,
          revenue: entry.value,
          share: entry.value / total,
        ),
      );
    }

    if (entries.length > limit) {
      final rest = entries.skip(limit).fold<double>(0, (s, e) => s + e.value);
      if (rest > 0) {
        shares.add(
          CategoryShare(name: 'Other', revenue: rest, share: rest / total),
        );
      }
    }

    return shares;
  }

  /// Best sellers by units moved inside the window.
  List<MapEntry<String, int>> topProducts({int limit = 5}) {
    final byProduct = <String, int>{};
    for (final order in ordersInRange.where(_isEarning)) {
      for (final item in order.items) {
        byProduct[item.productName] =
            (byProduct[item.productName] ?? 0) + item.quantity;
      }
    }
    final entries = byProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// How many orders sit at each lifecycle stage right now (all time, not
  /// windowed — the pipeline is about present workload).
  Map<String, int> get statusPipeline {
    final counts = <String, int>{for (final s in OrderStatuses.all) s: 0};
    for (final order in orders) {
      counts[order.orderStatus] = (counts[order.orderStatus] ?? 0) + 1;
    }
    return counts;
  }

  List<OrderModel> recentOrders({int limit = 6}) => orders.take(limit).toList();

  ProductModel? _productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  String customerNameFor(OrderModel order) {
    final shipping = order.shippingAddress.fullName.trim();
    if (shipping.isNotEmpty) return shipping;
    for (final user in users) {
      if (user.id == order.userId) return user.name;
    }
    return 'Guest';
  }
}
