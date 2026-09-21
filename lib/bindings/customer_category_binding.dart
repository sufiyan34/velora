import 'package:get/get.dart';

import '../controllers/customer_category_controller.dart';

class CustomerCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerCategoryController>(
      () => CustomerCategoryController(),
      fenix: true,
    );
  }
}
