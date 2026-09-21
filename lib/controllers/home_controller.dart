import 'dart:async';

import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../services/local_cache_service.dart';

class HomeController extends GetxController {
  HomeController({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  }) : _productRepository = productRepository ?? ProductRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository();

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  /// Home only shows curated sections (featured / new / on sale), so it
  /// never needs the whole catalog — just a recent window of it. This is
  /// the main fix for the slow Home load: before, every launch downloaded
  /// every product in the store.
  static const int _homeProductLimit = 60;

  static const String _productsCacheKey = 'cache_home_products';
  static const String _categoriesCacheKey = 'cache_home_categories';

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final RxBool isLoadingProducts = true.obs;
  final RxBool isLoadingCategories = true.obs;

  final RxString productError = ''.obs;
  final RxString categoryError = ''.obs;

  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;

  @override
  void onInit() {
    super.onInit();

    _loadFromCache();
    _listenToProducts();
    _listenToCategories();
  }

  /// Paints the screen instantly from whatever was cached on the last
  /// successful load, so returning users almost never see the skeleton —
  /// the live listeners below silently replace this the moment fresh data
  /// arrives.
  Future<void> _loadFromCache() async {
    final cachedProducts = await LocalCacheService.readJson(_productsCacheKey);

    if (cachedProducts is List && cachedProducts.isNotEmpty && products.isEmpty) {
      final parsed = cachedProducts
          .whereType<Map>()
          .map(
            (item) => ProductModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((product) => product.isActive)
          .toList();

      if (parsed.isNotEmpty) {
        products.assignAll(parsed);
        isLoadingProducts.value = false;
      }
    }

    final cachedCategories = await LocalCacheService.readJson(
      _categoriesCacheKey,
    );

    if (cachedCategories is List &&
        cachedCategories.isNotEmpty &&
        categories.isEmpty) {
      final parsed = cachedCategories
          .whereType<Map>()
          .map(
            (item) => CategoryModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((category) => category.isActive && category.isTopLevel)
          .toList();

      if (parsed.isNotEmpty) {
        categories.assignAll(parsed);
        isLoadingCategories.value = false;
      }
    }
  }

  void _listenToProducts() {
    productError.value = '';

    _productsSubscription = _productRepository
        .watchLatest(limit: _homeProductLimit)
        .listen(
          (items) {
            products.assignAll(items.where((product) => product.isActive));

            isLoadingProducts.value = false;

            // Write-through cache for the next cold start.
            LocalCacheService.saveJson(
              _productsCacheKey,
              items.map((product) => product.toMap()).toList(),
            );
          },
          onError: (error) {
            isLoadingProducts.value = false;
            productError.value = error.toString();
          },
        );
  }

  void _listenToCategories() {
    categoryError.value = '';

    _categoriesSubscription = _categoryRepository.watchAll().listen(
      (items) {
        categories.assignAll(
          items.where(
            (category) => category.isActive && category.isTopLevel,
          ),
        );

        isLoadingCategories.value = false;

        LocalCacheService.saveJson(
          _categoriesCacheKey,
          items.map((category) => category.toMap()).toList(),
        );
      },
      onError: (error) {
        isLoadingCategories.value = false;
        categoryError.value = error.toString();
      },
    );
  }

  // -----------------------------
  // Product Sections
  // -----------------------------

  List<ProductModel> get featuredProducts {
    final featured = products.where((product) => product.isFeatured).toList();

    // Fallback: show products if none are marked featured.
    if (featured.isEmpty) {
      return products.take(8).toList();
    }

    return featured;
  }

  List<ProductModel> get newArrivals {
    final newProducts = products.where((product) => product.isNew).toList();

    // Fallback: show recent products.
    if (newProducts.isEmpty) {
      return products.take(8).toList();
    }

    return newProducts;
  }

  List<ProductModel> get saleProducts {
    final saleProducts = products.where((product) => product.isOnSale).toList();

    // Only show this section when actual sale products exist.
    return saleProducts;
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  final RxString searchQuery = ''.obs;

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  List<ProductModel> get searchResults {
    final query = searchQuery.value;

    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name = product.name.toLowerCase();
      final brand = product.brand.toLowerCase();
      final category = product.categoryName.toLowerCase();
      final description = product.description.toLowerCase();

      return name.contains(query) ||
          brand.contains(query) ||
          category.contains(query) ||
          description.contains(query);
    }).toList();
  }

  bool get isLoading {
    return isLoadingProducts.value || isLoadingCategories.value;
  }

  /// True only while there is neither cached nor live data yet to show —
  /// this is the signal the Home screen uses to display the full-page
  /// skeleton instead of an empty section.
  bool get isInitialLoading {
    return isLoading && products.isEmpty && categories.isEmpty;
  }

  bool get hasProducts => products.isNotEmpty;

  bool get hasCategories => categories.isNotEmpty;

  Future<void> refreshHome() async {
    // Realtime Database streams update automatically.
    // This method exists so RefreshIndicator can be used
    // later on the mobile Home screen.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();

    super.onClose();
  }
}
