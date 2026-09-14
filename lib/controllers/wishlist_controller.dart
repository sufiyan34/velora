import 'package:get/get.dart';

import '../../models/product_model.dart';

class WishlistController extends GetxController {
  final RxList<ProductModel> wishlist = <ProductModel>[].obs;

  bool isInWishlist(String productId) {
    return wishlist.any((product) => product.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      wishlist.removeWhere((item) => item.id == product.id);
    } else {
      wishlist.add(product);
    }

    update();
  }

  void removeFromWishlist(String productId) {
    wishlist.removeWhere((product) => product.id == productId);
  }

  void clearWishlist() {
    wishlist.clear();
  }

  int get itemCount => wishlist.length;

  bool get isEmpty => wishlist.isEmpty;
}
