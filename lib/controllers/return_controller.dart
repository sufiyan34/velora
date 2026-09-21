import 'dart:async';

import 'package:get/get.dart';

import '../controllers/cloudinary_media_controller.dart';
import '../controllers/current_user_controller.dart';
import '../models/order_model.dart';
import '../models/return_request_model.dart';
import '../repositories/order_repository.dart';
import '../repositories/return_repository.dart';

class ReturnController extends GetxController {
  ReturnController({
    OrderRepository? orderRepository,
    ReturnRepository? returnRepository,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _returnRepository = returnRepository ?? ReturnRepository();

  final OrderRepository _orderRepository;
  final ReturnRepository _returnRepository;

  /// Orders can only be returned within this many days of delivery.
  static const int returnWindowDays = 14;

  // ============================================================
  // ORDERS + RETURN HISTORY
  // ============================================================

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<ReturnRequestModel> myReturns = <ReturnRequestModel>[].obs;

  final RxBool isLoadingOrders = true.obs;
  final RxBool isLoadingReturns = true.obs;

  StreamSubscription<List<OrderModel>>? _ordersSub;
  StreamSubscription<List<ReturnRequestModel>>? _returnsSub;

  /// 0 = file a new request, 1 = view request history.
  final RxInt viewMode = 0.obs;

  String? _preselectOrderId;
  bool _preselectApplied = false;

  // ============================================================
  // NEW REQUEST FORM STATE
  // ============================================================

  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  /// productId -> quantity to return. Presence of a key means the item
  /// is selected for this request.
  final RxMap<String, int> selectedQuantities = <String, int>{}.obs;

  final RxString reason = ''.obs;
  final RxString description = ''.obs;
  final RxString resolution = 'refund'.obs;

  final RxList<String> photoUrls = <String>[].obs;
  final RxBool isUploadingPhotos = false.obs;

  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString submittedRequestId = ''.obs;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is Map) {
      _preselectOrderId = arguments['orderId']?.toString();
    } else if (arguments is String) {
      _preselectOrderId = arguments;
    }

    final userId = CurrentUserController.to.userId;

    if (userId.isNotEmpty) {
      _listenToOrders(userId);
      _listenToReturns(userId);
    } else {
      isLoadingOrders.value = false;
      isLoadingReturns.value = false;
    }
  }

  void _listenToOrders(String userId) {
    isLoadingOrders.value = true;

    _ordersSub = _orderRepository.watchUserOrders(userId).listen(
      (items) {
        orders.assignAll(items);
        isLoadingOrders.value = false;
        _applyPreselectIfNeeded();
      },
      onError: (error) {
        isLoadingOrders.value = false;
        errorMessage.value = error.toString();
      },
    );
  }

  void _listenToReturns(String userId) {
    isLoadingReturns.value = true;

    _returnsSub = _returnRepository.watchUserReturns(userId).listen(
      (items) {
        myReturns.assignAll(items);
        isLoadingReturns.value = false;
      },
      onError: (error) {
        isLoadingReturns.value = false;
      },
    );
  }

  void _applyPreselectIfNeeded() {
    if (_preselectApplied) return;
    if (_preselectOrderId == null || _preselectOrderId!.isEmpty) return;

    final match = orders.firstWhereOrNull(
      (order) => order.id == _preselectOrderId,
    );

    if (match != null) {
      _preselectApplied = true;
      selectOrder(match);
    }
  }

  // ============================================================
  // DERIVED LISTS
  // ============================================================

  List<OrderModel> get deliveredOrders {
    return orders.where((order) => order.isDelivered).toList();
  }

  bool get isInitialLoading {
    return (isLoadingOrders.value || isLoadingReturns.value) &&
        orders.isEmpty &&
        myReturns.isEmpty;
  }

  bool hasActiveReturn(String orderId) {
    return myReturns.any(
      (request) => request.orderId == orderId && request.isActive,
    );
  }

  bool isEligible(OrderModel order) {
    return ineligibilityReason(order) == null;
  }

  /// Returns a short human-readable reason the order can't be returned
  /// right now, or null when it's eligible.
  String? ineligibilityReason(OrderModel order) {
    if (!order.isDelivered) {
      return 'Not yet delivered';
    }

    final deliveredAt = order.deliveredAt;

    if (deliveredAt != null) {
      final daysSinceDelivery = DateTime.now().difference(deliveredAt).inDays;

      if (daysSinceDelivery > returnWindowDays) {
        return 'Return window expired';
      }
    }

    if (hasActiveReturn(order.id)) {
      return 'Return already requested';
    }

    return null;
  }

  // ============================================================
  // FORM ACTIONS
  // ============================================================

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
    selectedQuantities.clear();
    errorMessage.value = '';
  }

  void clearSelectedOrder() {
    selectedOrder.value = null;
    selectedQuantities.clear();
  }

  bool isItemSelected(String productId) {
    return selectedQuantities.containsKey(productId);
  }

  void toggleItem(OrderItem item) {
    if (selectedQuantities.containsKey(item.productId)) {
      selectedQuantities.remove(item.productId);
    } else {
      selectedQuantities[item.productId] = item.quantity;
    }
  }

  void setItemQuantity(OrderItem item, int quantity) {
    if (!selectedQuantities.containsKey(item.productId)) return;

    final clamped = quantity < 1
        ? 1
        : (quantity > item.quantity ? item.quantity : quantity);

    selectedQuantities[item.productId] = clamped;
  }

  void setReason(String value) => reason.value = value;

  void setDescription(String value) => description.value = value;

  void setResolution(String value) => resolution.value = value;

  bool get hasSelectedItems => selectedQuantities.isNotEmpty;

  bool get canSubmit {
    return selectedOrder.value != null &&
        hasSelectedItems &&
        reason.value.isNotEmpty &&
        !isSubmitting.value;
  }

  // ============================================================
  // PHOTO EVIDENCE (OPTIONAL)
  // ============================================================

  Future<void> pickAndUploadPhotos() async {
    if (photoUrls.length >= 4) {
      Get.snackbar(
        'Limit Reached',
        'You can attach up to 4 photos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploadingPhotos.value = true;

      final mediaController = Get.find<CloudinaryMediaController>();

      final orderId = selectedOrder.value?.id ?? 'general';

      final results = await mediaController.pickAndUploadImages(
        folder: 'velora/returns/$orderId',
        maxFiles: 4 - photoUrls.length,
      );

      final urls = results
          .map((result) => result.secureUrl.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (urls.isNotEmpty) {
        photoUrls.addAll(urls);
      }
    } catch (_) {
      Get.snackbar(
        'Upload Failed',
        'Unable to upload one or more photos. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingPhotos.value = false;
    }
  }

  void removePhoto(String url) {
    photoUrls.remove(url);
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<bool> submitRequest() async {
    final order = selectedOrder.value;

    if (order == null || !hasSelectedItems || reason.value.isEmpty) {
      return false;
    }

    final userId = CurrentUserController.to.userId;

    if (userId.isEmpty) {
      Get.snackbar(
        'Login Required',
        'Please login to request a return.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final returnItems = <ReturnItem>[];

      for (final item in order.items) {
        final quantity = selectedQuantities[item.productId];

        if (quantity == null || quantity <= 0) continue;

        returnItems.add(
          ReturnItem.fromOrderItem(item, returnQuantity: quantity),
        );
      }

      if (returnItems.isEmpty) {
        return false;
      }

      final request = ReturnRequestModel(
        id: '',
        userId: userId,
        orderId: order.id,
        items: returnItems,
        reason: reason.value,
        description: description.value.trim(),
        resolution: resolution.value,
        photoUrls: photoUrls.toList(),
      );

      final created = await _returnRepository.create(request);

      submittedRequestId.value = created.id;
      _resetForm();

      return true;
    } catch (error) {
      errorMessage.value = error.toString();

      Get.snackbar(
        'Request Failed',
        'Unable to submit your return request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    selectedOrder.value = null;
    selectedQuantities.clear();
    reason.value = '';
    description.value = '';
    resolution.value = 'refund';
    photoUrls.clear();
  }

  /// Called after the success view has been shown, to return to a clean
  /// "file a new request" form.
  void startAnotherRequest() {
    submittedRequestId.value = '';
    _resetForm();
  }

  void setViewMode(int index) => viewMode.value = index;

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    _ordersSub?.cancel();
    _returnsSub?.cancel();
    super.onClose();
  }
}
