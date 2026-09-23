import 'dart:async';

import 'package:get/get.dart';

import '../models/complaint_model.dart';
import '../repositories/complaint_repository.dart';

/// Drives the Complaints admin screen and its detail drawer: search, status
/// tabs, and every write action (change status / respond to customer).
class AdminComplaintsController extends GetxController {
  AdminComplaintsController({ComplaintRepository? repository})
    : _repo = repository ?? ComplaintRepository();

  final ComplaintRepository _repo;

  final complaints = <ComplaintModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  /// Complaint ID currently being written to — lets a single row show its
  /// own spinner instead of blocking the whole screen.
  final busyComplaintId = RxnString();

  final searchTerm = ''.obs;

  /// 'all' or one of [ComplaintStatuses.all].
  final statusFilter = 'all'.obs;

  StreamSubscription<List<ComplaintModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.watchAll().listen(
      (list) {
        complaints.assignAll(list);
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
    final map = <String, int>{'all': complaints.length};
    for (final status in ComplaintStatuses.all) {
      map[status] = complaints.where((c) => c.status == status).length;
    }
    return map;
  }

  List<ComplaintModel> get filtered {
    final term = searchTerm.value.trim().toLowerCase();
    return complaints.where((complaint) {
      final matchesStatus =
          statusFilter.value == 'all' || complaint.status == statusFilter.value;
      if (!matchesStatus) return false;
      if (term.isEmpty) return true;
      return complaint.subject.toLowerCase().contains(term) ||
          complaint.category.toLowerCase().contains(term) ||
          complaint.description.toLowerCase().contains(term) ||
          (complaint.orderId ?? '').toLowerCase().contains(term);
    }).toList();
  }

  ComplaintModel? byId(String id) {
    for (final complaint in complaints) {
      if (complaint.id == id) return complaint;
    }
    return null;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<bool> _run(String id, Future<void> Function() action) async {
    busyComplaintId.value = id;
    try {
      await action();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      Get.snackbar(
        'Something went wrong',
        'Unable to update this complaint. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (busyComplaintId.value == id) busyComplaintId.value = null;
    }
  }

  Future<bool> setStatus(String id, String status) =>
      _run(id, () => _repo.updateStatus(id: id, status: status));

  /// Reply shown back to the customer. Pass [status] to move the complaint's
  /// status in the same write (e.g. respond + mark resolved).
  Future<bool> respond(String id, String response, {String? status}) =>
      _run(id, () => _repo.respond(id: id, response: response, status: status));
}
