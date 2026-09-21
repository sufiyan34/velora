import 'dart:async';

import 'package:e_commerce/repositories/admin_repositery.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';

import '../repositories/order_repository.dart';
import '../utills/order_status_style.dart';

/// Drives the Orders admin screen and its detail drawer: search, status
/// tabs, and every write action (accept / reject / cancel / update status /
/// update payment status / admin note).
class AdminOrdersController extends GetxController {
  AdminOrdersController({
    AdminRepository? adminRepo,
    OrderRepository? orderRepo,
  }) : _adminRepo = adminRepo ?? AdminRepository(),
       _orderRepo = orderRepo ?? OrderRepository();

  final AdminRepository _adminRepo;
  final OrderRepository _orderRepo;

  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  /// Order ID currently being written to — lets a single row show its own
  /// spinner instead of blocking the whole screen.
  final busyOrderId = RxnString();

  final searchTerm = ''.obs;

  /// 'all' or one of [OrderStatuses.all].
  final statusFilter = 'all'.obs;

  StreamSubscription<List<OrderModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _adminRepo.watchAllOrders().listen(
      (list) {
        orders.assignAll(list);
        isLoading.value = false;
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value = error.toString();
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ============================================================
  // FILTERING
  // ============================================================

  Map<String, int> get counts {
    final map = <String, int>{'all': orders.length};
    for (final status in OrderStatuses.all) {
      map[status] = orders.where((o) => o.orderStatus == status).length;
    }
    return map;
  }

  List<OrderModel> get filtered {
    final term = searchTerm.value.trim().toLowerCase();
    return orders.where((order) {
      final matchesStatus =
          statusFilter.value == 'all' ||
          order.orderStatus == statusFilter.value;
      if (!matchesStatus) return false;
      if (term.isEmpty) return true;
      return order.id.toLowerCase().contains(term) ||
          order.shippingAddress.fullName.toLowerCase().contains(term) ||
          order.shippingAddress.phone.toLowerCase().contains(term) ||
          order.items.any((i) => i.productName.toLowerCase().contains(term));
    }).toList();
  }

  OrderModel? byId(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<bool> _run(String orderId, Future<void> Function() action) async {
    busyOrderId.value = orderId;
    try {
      await action();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      Get.snackbar(
        'Something went wrong',
        'Unable to update this order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyOrderId.value == orderId) busyOrderId.value = null;
    }
  }

  Future<bool> acceptOrder(String orderId) => _run(
    orderId,
    () => _orderRepo.updateOrderStatus(
      orderId: orderId,
      status: OrderStatuses.accepted,
    ),
  );

  Future<bool> rejectOrder(String orderId) => _run(
    orderId,
    () => _orderRepo.updateOrderStatus(
      orderId: orderId,
      status: OrderStatuses.rejected,
    ),
  );

  Future<bool> cancelOrder(String orderId) =>
      _run(orderId, () => _orderRepo.cancelOrder(orderId));

  Future<bool> setStatus(String orderId, String status) => _run(
    orderId,
    () => _orderRepo.updateOrderStatus(orderId: orderId, status: status),
  );

  Future<bool> setPaymentStatus(String orderId, String status) => _run(
    orderId,
    () =>
        _orderRepo.updatePaymentStatus(orderId: orderId, paymentStatus: status),
  );

  Future<bool> saveAdminNote(String orderId, String note) => _run(
    orderId,
    () => _orderRepo.updateAdminNote(orderId: orderId, note: note),
  );
}
