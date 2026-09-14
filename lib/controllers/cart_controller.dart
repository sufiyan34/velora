import 'package:get/get.dart';

import '../../models/cart_model.dart';
import '../../models/product_model.dart';

class CartController extends GetxController {
  final RxList<CartModel> items = <CartModel>[].obs;

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    ProductVariation? variation,
  }) {
    if (product.isOutOfStock) {
      Get.snackbar(
        'Out of Stock',
        '${product.name} is currently unavailable.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final variationId = variation?.id;

    final index = items.indexWhere(
      (item) => item.productId == product.id && item.variationId == variationId,
    );

    if (index != -1) {
      final existing = items[index];

      final newQuantity = existing.quantity + quantity;

      final safeQuantity = newQuantity > product.stock
          ? product.stock
          : newQuantity;

      items[index] = existing.copyWith(quantity: safeQuantity);
    } else {
      final safeQuantity = quantity > product.stock ? product.stock : quantity;

      final cartItem = CartModel(
        id: '${product.id}_${variation?.id ?? 'default'}',
        productId: product.id,
        productName: product.name,
        productImage: product.thumbnail,
        price: variation?.additionalPrice != null
            ? product.finalPrice + variation!.additionalPrice!
            : product.finalPrice,
        originalPrice: product.hasDiscount ? product.price : null,
        quantity: safeQuantity,
        variationId: variation?.id,
        variationName: variation?.name,
        variationValue: variation?.value,
        addedAt: DateTime.now(),
      );

      items.add(cartItem);
    }

    Get.snackbar(
      'Added to Cart',
      product.name,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void removeFromCart(String cartId) {
    items.removeWhere((item) => item.id == cartId);
  }

  void increaseQuantity(String cartId) {
    final index = items.indexWhere((item) => item.id == cartId);

    if (index == -1) return;

    final item = items[index];

    // We don't have the ProductModel inside CartModel,
    // so stock validation will be handled when the
    // product repository is connected to the cart.
    items[index] = item.copyWith(quantity: item.quantity + 1);
  }

  void decreaseQuantity(String cartId) {
    final index = items.indexWhere((item) => item.id == cartId);

    if (index == -1) return;

    final item = items[index];

    if (item.quantity <= 1) {
      removeFromCart(cartId);
      return;
    }

    items[index] = item.copyWith(quantity: item.quantity - 1);
  }

  void clearCart() {
    items.clear();
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  bool isInCart(String productId) {
    return items.any((item) => item.productId == productId);
  }

  int quantityOf(String productId) {
    return items
        .where((item) => item.productId == productId)
        .fold(0, (total, item) => total + item.quantity);
  }

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  double get subtotal {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }

  double get shipping {
    if (items.isEmpty) return 0;

    if (subtotal >= 5000) {
      return 0;
    }

    return 250;
  }

  double get total {
    return subtotal + shipping;
  }

  bool get isEmpty => items.isEmpty;
}
