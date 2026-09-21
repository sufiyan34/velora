import 'package:get/get.dart';

import '../controllers/customer_product_listing_controller.dart';

class CustomerProductListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerProductListingController>(
      () => CustomerProductListingController(),
      fenix: true,
    );
  }
}
