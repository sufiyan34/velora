import 'dart:async';

import 'package:get/get.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

/// Which curated Home section a "View All" tap came from.
enum ProductSectionType { featured, newArrivals, onSale }

class ProductSectionListingController extends GetxController {
  ProductSectionListingController({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  /// Products revealed per page — keeps a big result set feeling instant.
  static const int _pageSize = 16;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'recommended'.obs;
  final RxInt visibleCount = _pageSize.obs;

  ProductSectionType sectionType = ProductSectionType.featured;
  String title = 'Products';
  String subtitle = '';

  StreamSubscription<List<ProductModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is Map) {
      sectionType = _parseType(arguments['type']?.toString());
      title = arguments['title']?.toString() ?? _defaultTitle(sectionType);
      subtitle =
          arguments['subtitle']?.toString() ?? _defaultSubtitle(sectionType);
    } else if (arguments is String) {
      sectionType = _parseType(arguments);
      title = _defaultTitle(sectionType);
      subtitle = _defaultSubtitle(sectionType);
    } else {
      title = _defaultTitle(sectionType);
      subtitle = _defaultSubtitle(sectionType);
    }

    _listen();
  }

  ProductSectionType _parseType(String? value) {
    switch (value) {
      case 'new':
      case 'newArrivals':
      case 'new_arrivals':
        return ProductSectionType.newArrivals;
      case 'sale':
      case 'onSale':
      case 'on_sale':
        return ProductSectionType.onSale;
      default:
        return ProductSectionType.featured;
    }
  }

  String _defaultTitle(ProductSectionType type) {
    switch (type) {
      case ProductSectionType.newArrivals:
        return 'New Arrivals';
      case ProductSectionType.onSale:
        return 'On Sale';
      case ProductSectionType.featured:
        return 'Featured Products';
    }
  }

  String _defaultSubtitle(ProductSectionType type) {
    switch (type) {
      case ProductSectionType.newArrivals:
        return 'Fresh products added recently';
      case ProductSectionType.onSale:
        return 'Grab your favorites at better prices';
      case ProductSectionType.featured:
        return 'Handpicked products just for you';
    }
  }

  void _listen() {
    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _repository.watchAll().listen(
      (items) {
        products.assignAll(items.where((product) => product.isActive));
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  // ============================================================
  // FILTERING / SORTING / PAGINATION
  // ============================================================

  List<ProductModel> get _sectionProducts {
    switch (sectionType) {
      case ProductSectionType.featured:
        return products.where((product) => product.isFeatured).toList();
      case ProductSectionType.newArrivals:
        return products.where((product) => product.isNew).toList();
      case ProductSectionType.onSale:
        return products.where((product) => product.isOnSale).toList();
    }
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();

    final filtered = _sectionProducts.where((product) {
      if (query.isEmpty) return true;

      return product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);
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
        filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
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
