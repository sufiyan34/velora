import 'package:firebase_database/firebase_database.dart';

import '../models/complaint_model.dart';

class ComplaintRepository {
  ComplaintRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  // ============================================================
  // DATABASE REFERENCES
  // ============================================================

  DatabaseReference get _complaintsRef => _database.ref('complaints');

  DatabaseReference _userComplaintsRef(String userId) {
    return _database.ref('users/$userId/complaints');
  }

  // ============================================================
  // CREATE COMPLAINT
  // ============================================================

  Future<ComplaintModel> create(ComplaintModel complaint) async {
    final ref = _complaintsRef.push();
    final id = ref.key;

    if (id == null || id.isEmpty) {
      throw Exception('Unable to generate complaint ID.');
    }

    final now = DateTime.now();

    final newComplaint = complaint.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );

    // Save the complete complaint under:
    //
    // complaints/{complaintId}
    //
    // and a lightweight customer reference under:
    //
    // users/{userId}/complaints/{complaintId}

    await ref.set(newComplaint.toMap());

    await _userComplaintsRef(complaint.userId).child(id).set({
      'complaintId': id,
      'subject': newComplaint.subject,
      'category': newComplaint.category,
      'status': newComplaint.status,
      'createdAt': newComplaint.createdAt?.toIso8601String(),
    });

    return newComplaint;
  }

  // ============================================================
  // WATCH USER COMPLAINTS
  // ============================================================

  Stream<List<ComplaintModel>> watchUserComplaints(String userId) {
    return _complaintsRef.orderByChild('userId').equalTo(userId).onValue.map((
      event,
    ) {
      final value = event.snapshot.value;

      if (value is! Map) {
        return <ComplaintModel>[];
      }

      final data = Map<String, dynamic>.from(value);
      final complaints = <ComplaintModel>[];

      for (final entry in data.entries) {
        final complaintData = entry.value;

        if (complaintData is! Map) continue;

        complaints.add(
          ComplaintModel.fromMap(
            Map<String, dynamic>.from(complaintData),
            documentId: entry.key,
          ),
        );
      }

      _sortNewestFirst(complaints);

      return complaints;
    });
  }

  // ============================================================
  // WATCH ALL COMPLAINTS (ADMIN)
  // ============================================================

  /// Live stream of every complaint in the store, newest first. Used by the
  /// admin Complaints screen — the same role [AdminRepository.watchAllOrders]
  /// plays for orders.
  Stream<List<ComplaintModel>> watchAll() {
    return _complaintsRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value is! Map) {
        return <ComplaintModel>[];
      }

      final data = Map<String, dynamic>.from(value);
      final complaints = <ComplaintModel>[];

      for (final entry in data.entries) {
        final complaintData = entry.value;

        if (complaintData is! Map) continue;

        complaints.add(
          ComplaintModel.fromMap(
            Map<String, dynamic>.from(complaintData),
            documentId: entry.key.toString(),
          ),
        );
      }

      _sortNewestFirst(complaints);

      return complaints;
    });
  }

  void _sortNewestFirst(List<ComplaintModel> complaints) {
    complaints.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });
  }

  // ============================================================
  // GET SINGLE COMPLAINT
  // ============================================================

  Future<ComplaintModel?> getById(String id) async {
    if (id.trim().isEmpty) return null;

    final snapshot = await _complaintsRef.child(id).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final value = snapshot.value;

    if (value is! Map) return null;

    return ComplaintModel.fromMap(
      Map<String, dynamic>.from(value),
      documentId: id,
    );
  }

  // ============================================================
  // UPDATE STATUS (ADMIN)
  // ============================================================

  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('Complaint ID is required.');
    }

    final now = DateTime.now();

    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': now.toIso8601String(),
    };

    if (status == ComplaintStatuses.resolved ||
        status == ComplaintStatuses.closed) {
      updates['resolvedAt'] = now.toIso8601String();
    }

    await _complaintsRef.child(id).update(updates);

    await _mirrorStatusToUser(id: id, status: status, now: now);
  }

  // ============================================================
  // RESPOND (ADMIN) — reply shown back to the customer, optionally
  // moving the status at the same time (e.g. reply + mark resolved).
  // ============================================================

  Future<void> respond({
    required String id,
    required String response,
    String? status,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('Complaint ID is required.');
    }

    final now = DateTime.now();

    final updates = <String, dynamic>{
      'adminResponse': response.trim().isEmpty ? null : response.trim(),
      'updatedAt': now.toIso8601String(),
    };

    if (status != null) {
      updates['status'] = status;

      if (status == ComplaintStatuses.resolved ||
          status == ComplaintStatuses.closed) {
        updates['resolvedAt'] = now.toIso8601String();
      }
    }

    await _complaintsRef.child(id).update(updates);

    if (status != null) {
      await _mirrorStatusToUser(id: id, status: status, now: now);
    }
  }

  Future<void> _mirrorStatusToUser({
    required String id,
    required String status,
    required DateTime now,
  }) async {
    final snapshot = await _complaintsRef.child(id).child('userId').get();

    if (snapshot.exists && snapshot.value != null) {
      final userId = snapshot.value.toString();

      await _userComplaintsRef(userId).child(id).update({
        'status': status,
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Complaint ID is required.');
    }

    final snapshot = await _complaintsRef.child(id).get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final userId = data['userId']?.toString();

      await _complaintsRef.child(id).remove();

      if (userId != null && userId.isNotEmpty) {
        await _userComplaintsRef(userId).child(id).remove();
      }

      return;
    }

    await _complaintsRef.child(id).remove();
  }
}
