import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/product_section_listing_controller.dart';
import '../controllers/wishlist_controller.dart';

class ProductSectionListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductSectionListingController>(
      () => ProductSectionListingController(),
    );

    // The shared product card needs these to show wishlist/cart state —
    // registering them here (fenix: true, same as CartBinding /
    // WishlistBinding) guarantees they exist even if this screen is
    // opened without visiting Home first.
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
