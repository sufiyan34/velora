import 'package:firebase_database/firebase_database.dart';

import '../models/order_model.dart';

class OrderRepository {
  OrderRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  // ============================================================
  // DATABASE REFERENCES
  // ============================================================

  DatabaseReference get _ordersRef {
    return _database.ref('orders');
  }

  DatabaseReference _userOrdersRef(String userId) {
    return _database.ref('users/$userId/orders');
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<OrderModel> create(OrderModel order) async {
    final orderRef = _ordersRef.push();

    final orderId = orderRef.key;

    if (orderId == null || orderId.isEmpty) {
      throw Exception('Unable to generate order ID.');
    }

    final now = DateTime.now();

    final newOrder = order.copyWith(
      id: orderId,
      createdAt: now,
      updatedAt: now,
    );

    // Save the complete order under:
    //
    // orders/{orderId}
    //
    // and a lightweight customer reference under:
    //
    // users/{userId}/orders/{orderId}

    await orderRef.set(newOrder.toMap());

    await _userOrdersRef(order.userId).child(orderId).set({
      'orderId': orderId,
      'orderStatus': newOrder.orderStatus,
      'paymentStatus': newOrder.paymentStatus,
      'total': newOrder.total,
      'currency': newOrder.currency,
      'createdAt': newOrder.createdAt?.toIso8601String(),
    });

    return newOrder;
  }

  // ============================================================
  // GET ORDER BY ID
  // ============================================================

  Future<OrderModel?> getById(String orderId) async {
    if (orderId.trim().isEmpty) {
      return null;
    }

    final snapshot = await _ordersRef.child(orderId).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final value = snapshot.value;

    if (value is! Map) {
      return null;
    }

    final data = Map<String, dynamic>.from(value);

    return OrderModel.fromMap(data, documentId: orderId);
  }

  // ============================================================
  // WATCH USER ORDERS
  // ============================================================

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _ordersRef.orderByChild('userId').equalTo(userId).onValue.map((
      event,
    ) {
      final value = event.snapshot.value;

      if (value == null) {
        return <OrderModel>[];
      }

      if (value is! Map) {
        return <OrderModel>[];
      }

      final data = Map<String, dynamic>.from(value);

      final orders = <OrderModel>[];

      for (final entry in data.entries) {
        final orderData = entry.value;

        if (orderData is! Map) {
          continue;
        }

        orders.add(
          OrderModel.fromMap(
            Map<String, dynamic>.from(orderData),
            documentId: entry.key,
          ),
        );
      }

      // Newest orders first.
      orders.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      return orders;
    });
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (orderId.trim().isEmpty) {
      throw Exception('Order ID is required.');
    }

    final now = DateTime.now();

    final updates = <String, dynamic>{
      'orderStatus': status,
      'updatedAt': now.toIso8601String(),
    };

    // Add lifecycle timestamp according
    // to the new status.

    switch (status) {
      case 'accepted':
        updates['acceptedAt'] = now.toIso8601String();
        break;

      case 'dispatched':
        updates['dispatchedAt'] = now.toIso8601String();
        break;

      case 'delivered':
        updates['deliveredAt'] = now.toIso8601String();
        break;

      case 'cancelled':
      case 'rejected':
        updates['cancelledAt'] = now.toIso8601String();
        break;
    }

    await _ordersRef.child(orderId).update(updates);

    // Update customer order reference if
    // we know the user ID.

    final snapshot = await _ordersRef.child(orderId).child('userId').get();

    if (snapshot.exists && snapshot.value != null) {
      final userId = snapshot.value.toString();

      await _userOrdersRef(userId).child(orderId).update({
        'orderStatus': status,
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
    String? transactionId,
  }) async {
    if (orderId.trim().isEmpty) {
      throw Exception('Order ID is required.');
    }

    final now = DateTime.now();

    final updates = <String, dynamic>{
      'paymentStatus': paymentStatus,
      'updatedAt': now.toIso8601String(),
    };

    if (transactionId != null && transactionId.trim().isNotEmpty) {
      updates['transactionId'] = transactionId.trim();
    }

    await _ordersRef.child(orderId).update(updates);

    final snapshot = await _ordersRef.child(orderId).child('userId').get();

    if (snapshot.exists && snapshot.value != null) {
      final userId = snapshot.value.toString();

      await _userOrdersRef(userId).child(orderId).update({
        'paymentStatus': paymentStatus,
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> cancelOrder(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw Exception('Order ID is required.');
    }

    final now = DateTime.now();

    final updates = <String, dynamic>{
      'orderStatus': 'cancelled',
      'cancelledAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    await _ordersRef.child(orderId).update(updates);

    final snapshot = await _ordersRef.child(orderId).child('userId').get();

    if (snapshot.exists && snapshot.value != null) {
      final userId = snapshot.value.toString();

      await _userOrdersRef(userId).child(orderId).update({
        'orderStatus': 'cancelled',
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  // ============================================================
  // DELETE ORDER
  // ============================================================
  //
  // Normally we should NOT delete customer orders.
  // This method is kept for future admin functionality
  // if you decide that hard deletion is necessary.
  //

  Future<void> delete(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw Exception('Order ID is required.');
    }

    final snapshot = await _ordersRef.child(orderId).get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final userId = data['userId']?.toString();

      await _ordersRef.child(orderId).remove();

      if (userId != null && userId.isNotEmpty) {
        await _userOrdersRef(userId).child(orderId).remove();
      }

      return;
    }

    await _ordersRef.child(orderId).remove();
  }
}
