import 'dart:async';

import 'package:get/get.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class DealsController extends GetxController {
  DealsController({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  static const int _pageSize = 16;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'discount'.obs;
  final RxInt visibleCount = _pageSize.obs;

  /// 0 = all deals, 1 = 50%+, 2 = 30%+, 3 = 10%+.
  final RxInt minDiscountTier = 0.obs;

  /// Purely a visual sense of urgency — deals refresh daily at midnight,
  /// this is not a per-product deadline.
  final Rx<Duration> timeUntilRefresh = Duration.zero.obs;

  StreamSubscription<List<ProductModel>>? _subscription;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();

    _listen();
    _startCountdown();
  }

  void _listen() {
    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _repository.watchAll().listen(
      (items) {
        products.assignAll(
          items.where((product) => product.isActive && product.hasDiscount),
        );
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  void _startCountdown() {
    _updateCountdown();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);

    timeUntilRefresh.value = midnight.difference(now);
  }

  String get countdownLabel {
    final duration = timeUntilRefresh.value;

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  // ============================================================
  // TIERS
  // ============================================================

  static const List<String> tierLabels = [
    'All Deals',
    '50% Off+',
    '30% Off+',
    '10% Off+',
  ];

  static const List<double> _tierThresholds = [0, 50, 30, 10];

  void setTier(int index) {
    minDiscountTier.value = index;
    visibleCount.value = _pageSize;
  }

  int dealCountForTier(int index) {
    final threshold = _tierThresholds[index];

    return products
        .where((product) => product.discountPercentage >= threshold)
        .length;
  }

  // ============================================================
  // FILTERING / SORTING / PAGINATION
  // ============================================================

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final threshold = _tierThresholds[minDiscountTier.value];

    final filtered = products.where((product) {
      final matchesTier = product.discountPercentage >= threshold;

      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);

      return matchesTier && matchesSearch;
    }).toList();

    switch (sortBy.value) {
      case 'price_low':
        filtered.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;

      case 'price_high':
        filtered.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;

      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'newest':
        filtered.sort((a, b) {
          final aDate = a.createdAt;
          final bDate = b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        break;

      default:
        filtered.sort(
          (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
        );
    }

    return filtered;
  }

  List<ProductModel> get pagedProducts {
    final all = filteredProducts;

    if (visibleCount.value >= all.length) {
      return all;
    }

    return all.take(visibleCount.value).toList();
  }

  bool get hasMore => visibleCount.value < filteredProducts.length;

  void loadMore() {
    if (!hasMore) return;

    final maxCount = filteredProducts.length;
    final nextCount = visibleCount.value + _pageSize;

    visibleCount.value = nextCount > maxCount ? maxCount : nextCount;
  }

  int get resultCount => filteredProducts.length;

  /// The single biggest discount currently live — used for the hero
  /// banner headline ("Up to 62% OFF").
  double get topDiscount {
    if (products.isEmpty) return 0;

    return products
        .map((product) => product.discountPercentage)
        .reduce((a, b) => a > b ? a : b);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    visibleCount.value = _pageSize;
  }

  void setSort(String value) {
    sortBy.value = value;
    visibleCount.value = _pageSize;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }
}
