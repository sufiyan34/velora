import 'dart:async';

import 'package:get/get.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  CartController({CartRepository? cartRepository})
    : _cartRepository = cartRepository ?? CartRepository();

  final CartRepository _cartRepository;

  // ==========================================================
  // CART STATE
  // ==========================================================

  final RxList<CartModel> items = <CartModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxBool isUpdating = false.obs;

  final RxString errorMessage = ''.obs;

  StreamSubscription<List<CartModel>>? _cartSubscription;

  // ==========================================================
  // AUTH
  // ==========================================================

  AuthController? get _authController {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }

    return null;
  }

  String get userId => _authController?.userId ?? '';

  bool get isLoggedIn => userId.isNotEmpty;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    _startCartListener();
  }

  // ==========================================================
  // FIREBASE LISTENER
  // ==========================================================

  void _startCartListener() {
    _cartSubscription?.cancel();
    _cartSubscription = null;

    if (!isLoggedIn) {
      items.clear();
      isLoading.value = false;
      errorMessage.value = '';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _cartSubscription = _cartRepository
        .watchCart(userId)
        .listen(
          (cartItems) {
            items.assignAll(cartItems);

            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (error) {
            isLoading.value = false;
            errorMessage.value = 'Unable to load cart.';
          },
        );
  }

  /// Call after login or when authenticated
  /// user changes.
  void refreshUserCart() {
    _startCartListener();
  }

  // ==========================================================
  // ADD TO CART
  // ==========================================================

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    ProductVariation? variation,
    double? unitPriceOverride,
    double? originalUnitPriceOverride,
  }) async {
    // --------------------------------------------------------
    // LOGIN
    // --------------------------------------------------------

    if (!isLoggedIn) {
      _showLoginMessage();
      return;
    }

    // --------------------------------------------------------
    // PRODUCT VALIDATION
    // --------------------------------------------------------

    if (product.id.trim().isEmpty) {
      _showError('Cart Error', 'This product cannot be added to the cart.');
      return;
    }

    if (quantity <= 0) {
      _showError('Cart Error', 'Quantity must be at least 1.');
      return;
    }

    // --------------------------------------------------------
    // STOCK VALIDATION
    // --------------------------------------------------------

    final availableStock = _availableStock(product, variation);

    if (availableStock <= 0) {
      _showError('Out of Stock', 'This product is currently out of stock.');
      return;
    }

    if (quantity > availableStock) {
      _showError(
        'Stock Limit',
        'Only $availableStock item${availableStock == 1 ? '' : 's'} available.',
      );
      return;
    }

    // --------------------------------------------------------
    // PRICE CALCULATION
    // --------------------------------------------------------

    final effectivePrice = _calculateUnitPrice(
      product,
      variation,
      unitPriceOverride,
    );

    final effectiveOriginalPrice = _calculateOriginalPrice(
      product,
      variation,
      originalUnitPriceOverride,
    );

    if (effectivePrice < 0) {
      _showError('Cart Error', 'Invalid product price.');
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      // ------------------------------------------------------
      // FIND EXISTING PRODUCT + VARIATION
      // ------------------------------------------------------

      final existingItem = _findMatchingItem(product.id, variation);

      if (existingItem != null) {
        // ----------------------------------------------------
        // NEW TOTAL QUANTITY
        // ----------------------------------------------------

        final newQuantity = existingItem.quantity + quantity;

        if (newQuantity > availableStock) {
          _showError(
            'Stock Limit',
            'You can only add up to $availableStock item${availableStock == 1 ? '' : 's'} of this product.',
          );
          return;
        }

        // ----------------------------------------------------
        // UPDATE EXISTING ROW
        // ----------------------------------------------------

        final updatedItem = existingItem.copyWith(
          quantity: newQuantity,

          // Keep cart price synchronized
          // with the current product/variation.
          price: effectivePrice,

          originalPrice: effectiveOriginalPrice,
        );

        await _cartRepository.updateItem(userId, updatedItem);
      } else {
        // ----------------------------------------------------
        // CREATE NEW CART ITEM
        // ----------------------------------------------------

        final item = CartModel(
          id: '',
          productId: product.id,
          productName: product.name,
          productImage: product.thumbnail,

          price: effectivePrice,

          originalPrice: effectiveOriginalPrice,

          quantity: quantity,

          variationId: variation?.id,

          variationName: variation?.name,

          variationValue: variation?.value,

          addedAt: DateTime.now(),
        );

        await _cartRepository.addItem(userId, item);
      }

      Get.snackbar(
        'Added to Cart',
        variation == null
            ? '${product.name} has been added to your cart.'
            : '${product.name} (${variation.value}) has been added to your cart.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Unable to add item to cart.';

      Get.snackbar(
        'Cart Error',
        'Unable to add this item to your cart.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================================
  // PRICE HELPERS
  // ==========================================================

  double _calculateUnitPrice(
    ProductModel product,
    ProductVariation? variation,
    double? override,
  ) {
    if (override != null) {
      return override < 0 ? 0 : override;
    }

    final variationExtra = variation?.additionalPrice ?? 0;

    return product.finalPrice + variationExtra;
  }

  double? _calculateOriginalPrice(
    ProductModel product,
    ProductVariation? variation,
    double? override,
  ) {
    if (override != null) {
      return override < 0 ? null : override;
    }

    if (!product.hasDiscount) {
      return null;
    }

    final variationExtra = variation?.additionalPrice ?? 0;

    return product.price + variationExtra;
  }

  // ==========================================================
  // STOCK HELPER
  // ==========================================================

  int _availableStock(ProductModel product, ProductVariation? variation) {
    if (variation != null && variation.stock >= 0) {
      return variation.stock;
    }

    return product.stock;
  }

  // ==========================================================
  // REMOVE
  // ==========================================================

  Future<void> removeFromCart(String cartId) async {
    if (!isLoggedIn || cartId.isEmpty) {
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _cartRepository.removeItem(userId, cartId);

      Get.snackbar(
        'Removed',
        'Item removed from your cart.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Unable to remove item.';

      Get.snackbar(
        'Cart Error',
        'Unable to remove this item.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================================
  // INCREASE
  // ==========================================================

  Future<void> increaseQuantity(String cartId) async {
    final index = items.indexWhere((item) => item.id == cartId);

    if (index == -1) {
      return;
    }

    final item = items[index];

    await _updateQuantity(item, item.quantity + 1);
  }

  // ==========================================================
  // DECREASE
  // ==========================================================

  Future<void> decreaseQuantity(String cartId) async {
    final index = items.indexWhere((item) => item.id == cartId);

    if (index == -1) {
      return;
    }

    final item = items[index];

    if (item.quantity <= 1) {
      await removeFromCart(cartId);
      return;
    }

    await _updateQuantity(item, item.quantity - 1);
  }

  // ==========================================================
  // UPDATE QUANTITY
  // ==========================================================

  Future<void> _updateQuantity(CartModel item, int quantity) async {
    if (!isLoggedIn || quantity <= 0) {
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final updatedItem = item.copyWith(quantity: quantity);

      await _cartRepository.updateItem(userId, updatedItem);
    } catch (e) {
      errorMessage.value = 'Unable to update quantity.';

      Get.snackbar(
        'Cart Error',
        'Unable to update item quantity.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  Future<void> clearCart() async {
    if (!isLoggedIn || items.isEmpty) {
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _cartRepository.clearCart(userId);

      Get.snackbar(
        'Cart Cleared',
        'All items have been removed.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Unable to clear cart.';

      Get.snackbar(
        'Cart Error',
        'Unable to clear your cart.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================================
  // CART QUERIES
  // ==========================================================

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  bool isInCart(String productId) {
    return containsProduct(productId);
  }

  int quantityOf(String productId) {
    return items
        .where((item) => item.productId == productId)
        .fold(0, (total, item) => total + item.quantity);
  }

  // ==========================================================
  // CART COUNTS
  // ==========================================================

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int get uniqueItemCount => items.length;

  // ==========================================================
  // TOTALS
  // ==========================================================

  double get subtotal {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }

  double get shipping {
    if (items.isEmpty) {
      return 0;
    }

    if (subtotal >= 5000) {
      return 0;
    }

    return 250;
  }

  double get total => subtotal + shipping;

  bool get isEmpty => items.isEmpty;

  // ==========================================================
  // FIND MATCHING PRODUCT + VARIATION
  // ==========================================================

  CartModel? _findMatchingItem(String productId, ProductVariation? variation) {
    return items.firstWhereOrNull((item) {
      if (item.productId != productId) {
        return false;
      }

      final currentVariationId = variation?.id;

      return item.variationId == currentVariationId;
    });
  }

  // ==========================================================
  // ERROR HELPERS
  // ==========================================================

  void _showLoginMessage() {
    Get.snackbar(
      'Login Required',
      'Please login before adding items to your cart.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showError(String title, String message) {
    errorMessage.value = message;

    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  /// Clears only local state.
  ///
  /// Firebase cart remains untouched so that
  /// the user's cart is available after login.
  void clearLocalCart() {
    _cartSubscription?.cancel();
    _cartSubscription = null;

    items.clear();

    isLoading.value = false;
    isUpdating.value = false;
    errorMessage.value = '';
  }

  // ==========================================================
  // CLOSE
  // ==========================================================

  @override
  void onClose() {
    _cartSubscription?.cancel();
    _cartSubscription = null;

    super.onClose();
  }
}
