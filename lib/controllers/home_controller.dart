import 'dart:async';

import 'package:get/get.dart';

import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../repositories/category_repository.dart';
import '../../../repositories/product_repository.dart';

class HomeController extends GetxController {
  HomeController({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  }) : _productRepository = productRepository ?? ProductRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository();

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

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

    _listenToProducts();
    _listenToCategories();
  }

  void _listenToProducts() {
    isLoadingProducts.value = true;
    productError.value = '';

    _productsSubscription = _productRepository.watchAll().listen(
      (items) {
        products.assignAll(items.where((product) => product.isActive));

        isLoadingProducts.value = false;
      },
      onError: (error) {
        isLoadingProducts.value = false;
        productError.value = error.toString();
      },
    );
  }

  void _listenToCategories() {
    isLoadingCategories.value = true;
    categoryError.value = '';

    _categoriesSubscription = _categoryRepository.watchAll().listen(
      (items) {
        categories.assignAll(items.where((category) => category.isActive));

        isLoadingCategories.value = false;
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
