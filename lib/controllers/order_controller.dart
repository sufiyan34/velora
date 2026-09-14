import 'dart:async';

import 'package:get/get.dart';

import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository();

  final OrderRepository _orderRepository;

  // ============================================================
  // STATE
  // ============================================================

  final RxList<OrderModel> orders = <OrderModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;

  final RxString errorMessage = ''.obs;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  // ============================================================
  // LOAD USER ORDERS
  // ============================================================

  void listenToUserOrders(String userId) {
    if (userId.trim().isEmpty) {
      errorMessage.value = 'User ID is required.';
      return;
    }

    _ordersSubscription?.cancel();

    isLoading.value = true;
    errorMessage.value = '';

    _ordersSubscription = _orderRepository
        .watchUserOrders(userId)
        .listen(
          (items) {
            orders.assignAll(items);
            isLoading.value = false;
          },
          onError: (error) {
            isLoading.value = false;
            errorMessage.value = error.toString();
          },
        );
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';

      final createdOrder = await _orderRepository.create(order);

      return createdOrder;
    } catch (error) {
      errorMessage.value = error.toString();

      Get.snackbar(
        'Order Failed',
        'Unable to create your order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      isCreating.value = false;
    }
  }

  // ============================================================
  // GET SINGLE ORDER
  // ============================================================

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      return await _orderRepository.getById(orderId);
    } catch (error) {
      errorMessage.value = error.toString();
      return null;
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    }
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================

  Future<bool> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
    String? transactionId,
  }) async {
    try {
      await _orderRepository.updatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
      );

      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      return false;
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _orderRepository.cancelOrder(orderId);
      return true;
    } catch (error) {
      errorMessage.value = error.toString();

      Get.snackbar(
        'Cancellation Failed',
        'Unable to cancel the order.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  OrderModel? getOrderFromList(String orderId) {
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  List<OrderModel> get pendingOrders {
    return orders.where((order) => order.isPending).toList();
  }

  List<OrderModel> get activeOrders {
    return orders.where((order) {
      return !order.isDelivered && !order.isCancelled && !order.isRejected;
    }).toList();
  }

  List<OrderModel> get completedOrders {
    return orders.where((order) => order.isDelivered).toList();
  }

  List<OrderModel> get cancelledOrders {
    return orders.where((order) {
      return order.isCancelled || order.isRejected;
    }).toList();
  }

  bool get hasOrders => orders.isNotEmpty;

  int get orderCount => orders.length;

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }
}
