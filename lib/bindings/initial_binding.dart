import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cloudinary_media_controller.dart';
import '../services/cloudinary/cloudinary_config.dart';
import '../services/cloudinary/cloudinary_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Cloudinary configuration
    Get.lazyPut<CloudinaryConfig>(
      () => CloudinaryConfig.fromEnvironment(),
      fenix: true,
    );

    // Cloudinary service
    Get.lazyPut<CloudinaryService>(
      () => CloudinaryService(config: Get.find<CloudinaryConfig>()),
      fenix: true,
    );

    // Cloudinary upload controller
    Get.lazyPut<CloudinaryMediaController>(
      () => CloudinaryMediaController(service: Get.find<CloudinaryService>()),
      fenix: true,
    );

    // Cart can stay disabled here for now
    // Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
