import 'dart:async';

import 'package:e_commerce/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../../models/product_model.dart';
import '../../repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  WishlistController({WishlistRepository? wishlistRepository})
    : _wishlistRepository = wishlistRepository ?? WishlistRepository();

  final WishlistRepository _wishlistRepository;

  /// Product IDs stored in Firebase.
  final RxList<String> wishlistIds = <String>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<String>>? _wishlistSubscription;

  AuthController? get _authController {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }

    return null;
  }

  String get userId => _authController?.userId ?? '';

  bool get isLoggedIn => userId.isNotEmpty;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    _startWishlistListener();
  }

  // ==========================================================
  // FIREBASE LISTENER
  // ==========================================================

  void _startWishlistListener() {
    _wishlistSubscription?.cancel();
    _wishlistSubscription = null;

    if (!isLoggedIn) {
      wishlistIds.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _wishlistSubscription = _wishlistRepository
        .watchWishlist(userId)
        .listen(
          (ids) {
            wishlistIds.assignAll(ids);

            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (error) {
            isLoading.value = false;
            errorMessage.value = 'Unable to load wishlist.';
          },
        );
  }

  /// Restart wishlist listener after login.
  void refreshUserWishlist() {
    _startWishlistListener();
  }

  /// Clear local wishlist when user logs out.
  void clearLocalWishlist() {
    _wishlistSubscription?.cancel();
    _wishlistSubscription = null;

    wishlistIds.clear();
  }

  // ==========================================================
  // WISHLIST ACTIONS
  // ==========================================================

  bool isInWishlist(String productId) {
    return wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(ProductModel product) async {
    if (!isLoggedIn) {
      _showLoginMessage();
      return;
    }

    if (product.id.isEmpty) {
      return;
    }

    try {
      isUpdating.value = true;
      errorMessage.value = '';

      if (isInWishlist(product.id)) {
        await _wishlistRepository.remove(userId, product.id);

        Get.snackbar(
          'Removed',
          '${product.name} removed from wishlist.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _wishlistRepository.add(userId, product.id);

        Get.snackbar(
          'Added to Wishlist',
          '${product.name} added to your wishlist.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = 'Unable to update wishlist.';

      Get.snackbar(
        'Wishlist Error',
        'Unable to update your wishlist.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    if (!isLoggedIn || productId.isEmpty) {
      return;
    }

    try {
      isUpdating.value = true;

      await _wishlistRepository.remove(userId, productId);

      Get.snackbar(
        'Removed',
        'Product removed from wishlist.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Unable to remove wishlist item.';

      Get.snackbar(
        'Wishlist Error',
        'Unable to remove this product.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> clearWishlist() async {
    if (!isLoggedIn || wishlistIds.isEmpty) {
      return;
    }

    try {
      isUpdating.value = true;

      await _wishlistRepository.clear(userId);

      Get.snackbar(
        'Wishlist Cleared',
        'All wishlist items have been removed.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Unable to clear wishlist.';

      Get.snackbar(
        'Wishlist Error',
        'Unable to clear your wishlist.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================================
  // GETTERS
  // ==========================================================

  int get itemCount => wishlistIds.length;

  bool get isEmpty => wishlistIds.isEmpty;

  // ==========================================================
  // LOGIN MESSAGE
  // ==========================================================

  void _showLoginMessage() {
    Get.snackbar(
      'Login Required',
      'Please login before adding products to your wishlist.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==========================================================
  // CLEANUP
  // ==========================================================

  @override
  void onClose() {
    _wishlistSubscription?.cancel();
    _wishlistSubscription = null;

    super.onClose();
  }
}
