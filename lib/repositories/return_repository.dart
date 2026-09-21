import 'package:firebase_database/firebase_database.dart';

import '../models/return_request_model.dart';

class ReturnRepository {
  ReturnRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  // ============================================================
  // DATABASE REFERENCES
  // ============================================================

  DatabaseReference get _returnsRef => _database.ref('returns');

  DatabaseReference _userReturnsRef(String userId) {
    return _database.ref('users/$userId/returns');
  }

  DatabaseReference get _ordersRef => _database.ref('orders');

  // ============================================================
  // CREATE RETURN REQUEST
  // ============================================================

  Future<ReturnRequestModel> create(ReturnRequestModel request) async {
    final ref = _returnsRef.push();
    final id = ref.key;

    if (id == null || id.isEmpty) {
      throw Exception('Unable to generate return request ID.');
    }

    final now = DateTime.now();

    final newRequest = request.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );

    // Save the complete request under:
    //
    // returns/{returnId}
    //
    // and a lightweight customer reference under:
    //
    // users/{userId}/returns/{returnId}

    await ref.set(newRequest.toMap());

    await _userReturnsRef(request.userId).child(id).set({
      'returnId': id,
      'orderId': newRequest.orderId,
      'status': newRequest.status,
      'itemCount': newRequest.itemCount,
      'createdAt': newRequest.createdAt?.toIso8601String(),
    });

    // Non-destructive flag on the order itself, so a future admin screen
    // can spot orders with an open return without scanning the whole
    // `returns` table.
    try {
      await _ordersRef.child(request.orderId).update({
        'hasReturnRequest': true,
        'returnStatus': newRequest.status,
      });
    } catch (_) {
      // The return request itself already saved successfully — a failure
      // to tag the order is not fatal to the customer's request.
    }

    return newRequest;
  }

  // ============================================================
  // WATCH USER RETURN REQUESTS
  // ============================================================

  Stream<List<ReturnRequestModel>> watchUserReturns(String userId) {
    return _returnsRef.orderByChild('userId').equalTo(userId).onValue.map((
      event,
    ) {
      final value = event.snapshot.value;

      if (value is! Map) {
        return <ReturnRequestModel>[];
      }

      final data = Map<String, dynamic>.from(value);
      final requests = <ReturnRequestModel>[];

      for (final entry in data.entries) {
        final requestData = entry.value;

        if (requestData is! Map) {
          continue;
        }

        requests.add(
          ReturnRequestModel.fromMap(
            Map<String, dynamic>.from(requestData),
            documentId: entry.key,
          ),
        );
      }

      // Newest requests first.
      requests.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return requests;
    });
  }

  // ============================================================
  // GET SINGLE RETURN REQUEST
  // ============================================================

  Future<ReturnRequestModel?> getById(String id) async {
    if (id.trim().isEmpty) {
      return null;
    }

    final snapshot = await _returnsRef.child(id).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final value = snapshot.value;

    if (value is! Map) {
      return null;
    }

    return ReturnRequestModel.fromMap(
      Map<String, dynamic>.from(value),
      documentId: id,
    );
  }
}
