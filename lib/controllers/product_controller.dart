import 'dart:math';

import 'package:get/get.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

/// Drives the Products admin screen: search, category filter, status filter
/// (active / inactive / low stock / out of stock), and CRUD.
class ProductController extends GetxController {
  ProductController({ProductRepository? repository})
    : _repo = repository ?? ProductRepository();

  final ProductRepository _repo;

  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  /// Product ID currently being written to — lets the Inventory screen show
  /// a per-row spinner instead of blocking the whole list.
  final busyProductId = RxnString();

  final searchTerm = ''.obs;
  final categoryFilter = ''.obs; // '' = all categories
  final statusFilter = 'all'.obs; // all | active | inactive | low | out

  @override
  void onInit() {
    super.onInit();
    _repo.watchAll().listen((list) {
      products.assignAll(list);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  List<ProductModel> get filtered {
    final term = searchTerm.value.trim().toLowerCase();
    return products.where((p) {
      final matchesTerm =
          term.isEmpty ||
          p.name.toLowerCase().contains(term) ||
          p.sku.toLowerCase().contains(term) ||
          p.brand.toLowerCase().contains(term);
      final matchesCategory =
          categoryFilter.value.isEmpty || p.categoryId == categoryFilter.value;
      final matchesStatus = switch (statusFilter.value) {
        'active' => p.isActive,
        'inactive' => !p.isActive,
        'low' => p.isLowStock,
        'out' => p.isOutOfStock,
        _ => true,
      };
      return matchesTerm && matchesCategory && matchesStatus;
    }).toList();
  }

  /// A friendly, human-editable SKU suggestion for a brand-new product —
  /// the admin can still override it before saving.
  String suggestSku() {
    final rand = Random();
    final code = List.generate(
      5,
      (_) => rand.nextInt(36),
    ).map((n) => n.toRadixString(36).toUpperCase()).join();
    return 'VLR-$code';
  }

  Future<void> addProduct(ProductModel product) async {
    isSaving.value = true;
    try {
      await _repo.create(product);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    isSaving.value = true;
    try {
      await _repo.update(product);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(String id) => _repo.delete(id);

  // ============================================================
  // INVENTORY — stock counts + adjustments
  // ============================================================

  int get lowStockCount => products.where((p) => p.isLowStock).length;

  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  double get inventoryValue =>
      products.fold(0, (sum, p) => sum + (p.finalPrice * p.stock));

  Future<bool> setStock(String id, int stock) async {
    busyProductId.value = id;
    try {
      await _repo.setStock(id: id, stock: stock);
      return true;
    } catch (_) {
      Get.snackbar(
        'Something went wrong',
        'Unable to update stock. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyProductId.value == id) busyProductId.value = null;
    }
  }

  Future<bool> adjustStock(String id, int delta) async {
    busyProductId.value = id;
    try {
      await _repo.adjustStock(id: id, delta: delta);
      return true;
    } catch (_) {
      Get.snackbar(
        'Something went wrong',
        'Unable to update stock. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyProductId.value == id) busyProductId.value = null;
    }
  }

  // ============================================================
  // DEALS — putting a product on/off sale
  // ============================================================

  /// Products currently discounted and active — what the storefront's
  /// Deals screen shows.
  List<ProductModel> get activeDeals =>
      products.where((p) => p.isActive && p.hasDiscount).toList();

  /// Active products with no discount yet — candidates to put on sale.
  List<ProductModel> get dealCandidates =>
      products.where((p) => p.isActive && !p.hasDiscount).toList();

  Future<bool> setDeal(String id, double salePrice) async {
    busyProductId.value = id;
    try {
      await _repo.setDeal(id: id, salePrice: salePrice);
      return true;
    } catch (_) {
      Get.snackbar(
        'Something went wrong',
        'Unable to save this deal. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyProductId.value == id) busyProductId.value = null;
    }
  }

  Future<bool> clearDeal(String id) async {
    busyProductId.value = id;
    try {
      await _repo.clearDeal(id: id);
      return true;
    } catch (_) {
      Get.snackbar(
        'Something went wrong',
        'Unable to remove this deal. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyProductId.value == id) busyProductId.value = null;
    }
  }
}
