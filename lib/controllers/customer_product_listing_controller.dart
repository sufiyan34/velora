import 'dart:async';

import 'package:get/get.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class CustomerProductListingController extends GetxController {
  CustomerProductListingController({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  /// Products revealed per page. Keeping the grid small at first is what
  /// makes a big category feel instant instead of building (and loading
  /// the images for) hundreds of cards in one frame.
  static const int _pageSize = 20;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'recommended'.obs;
  final RxInt visibleCount = _pageSize.obs;

  String categoryId = '';

  StreamSubscription<List<ProductModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments is Map) {
      categoryId = arguments['categoryId']?.toString() ?? '';
    }

    if (arguments is String) {
      categoryId = arguments;
    }

    _listen();
  }

  void _listen() {
    isLoading.value = true;
    errorMessage.value = '';

    // Filter on the server when we know the category — this is the
    // pagination-adjacent fix for slow category screens: only the
    // matching products come down the wire instead of the whole catalog.
    final stream = categoryId.isEmpty
        ? _repository.watchAll()
        : _repository.watchByCategory(categoryId);

    _subscription = stream.listen(
      (items) {
        products.assignAll(
          items.where((product) => product.isActive),
        );
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();

    final filtered = products.where((product) {
      final matchesCategory =
          categoryId.isEmpty || product.categoryId == categoryId;

      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    switch (sortBy.value) {
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

      case 'price_low':
        filtered.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;

      case 'price_high':
        filtered.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;

      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'discount':
        filtered.sort(
          (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
        );
        break;

      default:
        filtered.sort((a, b) {
          if (a.isFeatured != b.isFeatured) {
            return a.isFeatured ? -1 : 1;
          }
          if (a.isNew != b.isNew) {
            return a.isNew ? -1 : 1;
          }
          return b.soldCount.compareTo(a.soldCount);
        });
    }

    return filtered;
  }

  /// Only the current page's worth of [filteredProducts]. The grid grows
  /// this as the user scrolls (see [loadMore]) instead of rendering — and
  /// loading every product image for — the entire category at once.
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

    // `int.clamp()` returns `num` in Dart, which can't be assigned
    // straight back into an `RxInt` — so this is done with a plain
    // comparison instead.
    visibleCount.value = nextCount > maxCount ? maxCount : nextCount;
  }

  int get resultCount => filteredProducts.length;

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
    super.onClose();
  }
}
