import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/deals_controller.dart';
import '../controllers/wishlist_controller.dart';

class DealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealsController>(() => DealsController());

    // Needed by the shared product card for wishlist/cart state.
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
