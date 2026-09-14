import 'package:e_commerce/controllers/cart_controller.dart';
import 'package:e_commerce/controllers/home_controller.dart';
import 'package:e_commerce/controllers/wishlist_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
