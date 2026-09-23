import 'dart:async';

import 'package:get/get.dart';

import '../controllers/cloudinary_media_controller.dart';
import '../controllers/current_user_controller.dart';
import '../models/complaint_model.dart';
import '../models/order_model.dart';
import '../repositories/complaint_repository.dart';
import '../repositories/order_repository.dart';

class ComplaintController extends GetxController {
  ComplaintController({
    ComplaintRepository? complaintRepository,
    OrderRepository? orderRepository,
  }) : _complaintRepository = complaintRepository ?? ComplaintRepository(),
       _orderRepository = orderRepository ?? OrderRepository();

  final ComplaintRepository _complaintRepository;
  final OrderRepository _orderRepository;

  // ============================================================
  // ORDERS (optional "related order" picker) + COMPLAINT HISTORY
  // ============================================================

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<ComplaintModel> myComplaints = <ComplaintModel>[].obs;

  final RxBool isLoadingOrders = true.obs;
  final RxBool isLoadingComplaints = true.obs;

  StreamSubscription<List<OrderModel>>? _ordersSub;
  StreamSubscription<List<ComplaintModel>>? _complaintsSub;

  /// 0 = file a new complaint, 1 = view complaint history.
  final RxInt viewMode = 0.obs;

  String? _preselectOrderId;

  // ============================================================
  // NEW COMPLAINT FORM STATE
  // ============================================================

  final RxString subject = ''.obs;
  final RxString category = ''.obs;
  final RxString description = ''.obs;

  /// Optional — the order this complaint is about, if any.
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  final RxList<String> photoUrls = <String>[].obs;
  final RxBool isUploadingPhotos = false.obs;

  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString submittedComplaintId = ''.obs;

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
      _listenToComplaints(userId);
    } else {
      isLoadingOrders.value = false;
      isLoadingComplaints.value = false;
    }
  }

  void _listenToOrders(String userId) {
    isLoadingOrders.value = true;

    _ordersSub = _orderRepository
        .watchUserOrders(userId)
        .listen(
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

  void _listenToComplaints(String userId) {
    isLoadingComplaints.value = true;

    _complaintsSub = _complaintRepository
        .watchUserComplaints(userId)
        .listen(
          (items) {
            myComplaints.assignAll(items);
            isLoadingComplaints.value = false;
          },
          onError: (_) {
            isLoadingComplaints.value = false;
          },
        );
  }

  void _applyPreselectIfNeeded() {
    if (_preselectOrderId == null || _preselectOrderId!.isEmpty) return;

    final match = orders.firstWhereOrNull(
      (order) => order.id == _preselectOrderId,
    );

    if (match != null) {
      selectedOrder.value = match;
    }
  }

  bool get isInitialLoading {
    return (isLoadingOrders.value || isLoadingComplaints.value) &&
        orders.isEmpty &&
        myComplaints.isEmpty;
  }

  // ============================================================
  // FORM ACTIONS
  // ============================================================

  void setSubject(String value) => subject.value = value;

  void setCategory(String value) => category.value = value;

  void setDescription(String value) => description.value = value;

  void selectOrder(OrderModel? order) => selectedOrder.value = order;

  bool get canSubmit {
    return subject.value.trim().isNotEmpty &&
        category.value.isNotEmpty &&
        description.value.trim().isNotEmpty &&
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

      final userId = CurrentUserController.to.userId;

      final results = await mediaController.pickAndUploadImages(
        folder: 'velora/complaints/${userId.isEmpty ? 'general' : userId}',
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

  Future<bool> submitComplaint() async {
    if (!canSubmit) return false;

    final userId = CurrentUserController.to.userId;

    if (userId.isEmpty) {
      Get.snackbar(
        'Login Required',
        'Please login to submit a complaint.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final complaint = ComplaintModel(
        id: '',
        userId: userId,
        orderId: selectedOrder.value?.id,
        subject: subject.value.trim(),
        category: category.value,
        description: description.value.trim(),
        photoUrls: photoUrls.toList(),
      );

      final created = await _complaintRepository.create(complaint);

      submittedComplaintId.value = created.id;
      _resetForm();

      return true;
    } catch (error) {
      errorMessage.value = error.toString();

      Get.snackbar(
        'Submission Failed',
        'Unable to submit your complaint. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    subject.value = '';
    category.value = '';
    description.value = '';
    selectedOrder.value = null;
    photoUrls.clear();
  }

  /// Called after the success view has been shown, to return to a clean
  /// "file a new complaint" form.
  void startAnotherComplaint() {
    submittedComplaintId.value = '';
    _resetForm();
  }

  void setViewMode(int index) => viewMode.value = index;

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    _ordersSub?.cancel();
    _complaintsSub?.cancel();
    super.onClose();
  }
}
