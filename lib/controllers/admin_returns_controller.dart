import 'dart:async';

import 'package:get/get.dart';

import '../models/return_request_model.dart';
import '../repositories/return_repository.dart';

/// Drives the Returns admin screen and its detail drawer: search, status
/// tabs, and every write action (approve / reject / complete, with an
/// optional note back to the customer).
class AdminReturnsController extends GetxController {
  AdminReturnsController({ReturnRepository? repository})
    : _repo = repository ?? ReturnRepository();

  final ReturnRepository _repo;

  final returns = <ReturnRequestModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  /// Return request ID currently being written to — lets a single row show
  /// its own spinner instead of blocking the whole screen.
  final busyReturnId = RxnString();

  final searchTerm = ''.obs;

  /// 'all' or one of [ReturnStatuses.all].
  final statusFilter = 'all'.obs;

  StreamSubscription<List<ReturnRequestModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.watchAll().listen(
      (list) {
        returns.assignAll(list);
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
    final map = <String, int>{'all': returns.length};
    for (final status in ReturnStatuses.all) {
      map[status] = returns.where((r) => r.status == status).length;
    }
    return map;
  }

  List<ReturnRequestModel> get filtered {
    final term = searchTerm.value.trim().toLowerCase();
    return returns.where((request) {
      final matchesStatus =
          statusFilter.value == 'all' || request.status == statusFilter.value;
      if (!matchesStatus) return false;
      if (term.isEmpty) return true;
      return request.orderId.toLowerCase().contains(term) ||
          request.reason.toLowerCase().contains(term) ||
          request.resolution.toLowerCase().contains(term) ||
          request.items.any(
            (item) => item.productName.toLowerCase().contains(term),
          );
    }).toList();
  }

  ReturnRequestModel? byId(String id) {
    for (final request in returns) {
      if (request.id == id) return request;
    }
    return null;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<bool> _run(String id, Future<void> Function() action) async {
    busyReturnId.value = id;
    try {
      await action();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      Get.snackbar(
        'Something went wrong',
        'Unable to update this return request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyReturnId.value == id) busyReturnId.value = null;
    }
  }

  /// Change status, optionally attaching a note shown back to the customer.
  Future<bool> setStatus(String id, String status, {String? adminNote}) => _run(
    id,
    () => _repo.updateStatus(id: id, status: status, adminNote: adminNote),
  );
}
